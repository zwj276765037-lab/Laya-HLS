#!/usr/bin/env python3
"""Strict, bounded structural reader for a reviewed Vivado funcsim subset.

No Verilog is executed. Unsupported syntax is a terminal error, including
behavioral logic, positional ports, defparam, implicit nets and expressions.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import re


class Unsupported(ValueError):
    pass


@dataclass(frozen=True)
class Token:
    value: str
    start: int
    end: int


@dataclass(frozen=True)
class Literal:
    raw: str
    width: int | None
    signed: bool
    kind: str
    value: int | str
    start: int
    end: int


@dataclass
class Instance:
    reference: str
    name: str
    parameters: dict[str, Literal]
    ports: dict[str, object]


@dataclass
class Module:
    name: str
    header_ports: list[str] = field(default_factory=list)
    directions: dict[str, str] = field(default_factory=dict)
    ranges: dict[str, list[int]] = field(default_factory=dict)
    vector_ports: set[str] = field(default_factory=set)
    assigns: list[tuple[object, object]] = field(default_factory=list)
    instances: list[Instance] = field(default_factory=list)


@dataclass
class Primitive:
    path: str
    reference: str
    parameters: dict[str, Literal]
    ports: dict[str, list[str] | None]
    source_module: str
    source_instance: str


MAX_FILE_BYTES = 67108864
MAX_TOKENS = 1000000
MAX_MODULES = 128
MAX_PRIMITIVES = 256
MAX_NODES = 32768
MAX_EDGES = 65536
MAX_LITERAL_BITS = 4096
MAX_NUMERIC_TOKEN_BYTES = 8192
MAX_IDENTIFIER_BYTES = 1024
MAX_BUS_INDEX = 32767
MAX_EXPRESSION_DEPTH = 64
MAX_HIERARCHY_INSTANCES = 1024
MAX_HIERARCHY_DEPTH = 16
MAX_INSTANCE_DECLARATIONS = 4096
NUMBER = re.compile(r"(?:(\d+))?'([sS]?)([bBoOdDhH])([0-9a-fA-F_xXzZ?]+)\Z")
SIMPLE_NAME = re.compile(r"[A-Za-z_$][A-Za-z0-9_$]*\Z")
SIZED = re.compile(r"[0-9]+'[sS]?[bBoOdDhH][0-9a-fA-F_xXzZ?]+")


def decode_name(text: str) -> str:
    if len(text) > MAX_IDENTIFIER_BYTES:
        raise Unsupported("identifier byte cap exceeded")
    if text.startswith("\\"):
        if len(text) == 1:
            raise Unsupported("empty escaped identifier")
        return text[1:]  # Verilog escaped identifier ends at whitespace.
    if SIMPLE_NAME.fullmatch(text):
        return text
    raise Unsupported(f"unsupported identifier {text!r}")


def parse_literal(token: Token, *, allow_bare_word: bool = False) -> Literal:
    raw = token.value
    if token.start < 0 or token.end < token.start or token.end - token.start > MAX_NUMERIC_TOKEN_BYTES:
        raise Unsupported("literal source span cap exceeded")
    if len(raw) > MAX_NUMERIC_TOKEN_BYTES:
        raise Unsupported("literal token byte cap exceeded")
    if raw.startswith('"') and raw.endswith('"'):
        # Numeric model parameters are not evaluated from strings.
        value = bytes(raw[1:-1], "ascii").decode("unicode_escape")
        return Literal(raw, None, False, "string", value, token.start, token.end)
    match = NUMBER.fullmatch(raw)
    if match:
        width_s, sign, base_s, digits = match.groups()
        if any(x in digits.lower() for x in "xz?"):
            raise Unsupported(f"unknown numeric literal {raw!r}")
        base = {"b": 2, "o": 8, "d": 10, "h": 16}[base_s.lower()]
        if width_s is not None and (len(width_s) > 4 or int(width_s) > MAX_LITERAL_BITS):
            raise Unsupported(f"literal bit width cap exceeded {raw!r}")
        width = int(width_s) if width_s else None
        cleaned = digits.replace("_", "")
        if len(cleaned) > {2: 4096, 8: 1366, 10: 1234, 16: 1024}[base]:
            raise Unsupported(f"literal digit cap exceeded {raw!r}")
        value = int(cleaned, base)
        if value.bit_length() > MAX_LITERAL_BITS:
            raise Unsupported(f"literal value bit cap exceeded {raw!r}")
        if width is not None and (width <= 0 or value >= (1 << width)):
            raise Unsupported(f"literal width overflow {raw!r}")
        return Literal(raw, width, bool(sign), "integer", value, token.start, token.end)
    if re.fullmatch(r"\d[\d_]*", raw):
        cleaned = raw.replace("_", "")
        if len(cleaned) > 1234:
            raise Unsupported(f"literal digit cap exceeded {raw!r}")
        value = int(cleaned)
        if value.bit_length() > MAX_LITERAL_BITS:
            raise Unsupported(f"literal value bit cap exceeded {raw!r}")
        return Literal(raw, None, False, "integer", value, token.start, token.end)
    if allow_bare_word and SIMPLE_NAME.fullmatch(raw):
        return Literal(raw, None, False, "string", raw, token.start, token.end)
    raise Unsupported(f"unsupported literal {raw!r}")


def lex(source: str) -> list[Token]:
    try:
        source.encode("ascii")  # spans are byte spans by contract
    except UnicodeEncodeError as error:
        raise Unsupported("non-ASCII structural source") from error
    if len(source) > MAX_FILE_BYTES:
        raise Unsupported("functional export byte cap exceeded")
    out: list[Token] = []
    i, n = 0, len(source)
    while i < n:
        start = i
        if source[i].isspace():
            i += 1
            continue
        if source.startswith("//", i):
            i = source.find("\n", i)
            if i < 0:
                break
            continue
        if source.startswith("/*", i) or source.startswith("(*", i):
            close = "*/" if source.startswith("/*", i) else "*)"
            at = source.find(close, i + 2)
            if at < 0:
                raise Unsupported("unterminated comment or attribute")
            i = at + 2
            continue
        if source[i] == "`":
            line = source.find("\n", i)
            directive = source[i + 1:line if line >= 0 else n].split(None, 1)[0]
            if directive not in {"timescale", "celldefine", "endcelldefine", "default_nettype"}:
                raise Unsupported(f"unsupported preprocessor directive {directive}")
            i = line if line >= 0 else n
            continue
        if source[i] == "\\":
            i += 1
            while i < n and not source[i].isspace():
                i += 1
            if i == n:
                raise Unsupported("escaped identifier missing terminating whitespace")
        elif source[i] == '"':
            i += 1
            while i < n:
                if source[i] == "\\":
                    i += 2
                elif source[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
            if source[i - 1] != '"':
                raise Unsupported("unterminated string")
        elif source[i].isdigit():
            match = SIZED.match(source, i)
            if match:
                i = match.end()
            else:
                while i < n and (source[i].isdigit() or source[i] == "_"):
                    i += 1
        elif source[i] == "'":
            match = SIZED.match(source, i)
            if not match:
                raise Unsupported(f"unknown apostrophe token at {i}")
            i = match.end()
        elif source[i].isalpha() or source[i] in "_$":
            i += 1
            while i < n and (source[i].isalnum() or source[i] in "_$"):
                i += 1
        elif source[i] in "#.,;()[]{}:=+-":
            i += 1
        else:
            raise Unsupported(f"unsupported lexical character {source[i]!r} at {i}")
        out.append(Token(source[start:i], start, i))
        if i - start > MAX_NUMERIC_TOKEN_BYTES:
            raise Unsupported("token source span cap exceeded")
        if len(out) > MAX_TOKENS:
            raise Unsupported("token cap exceeded")
    return out


class Cursor:
    def __init__(self, tokens: list[Token]):
        self.tokens, self.at = tokens, 0

    def peek(self) -> str:
        return self.tokens[self.at].value if self.at < len(self.tokens) else ""

    def take(self) -> Token:
        if self.at >= len(self.tokens):
            raise Unsupported("unexpected end of Verilog")
        token = self.tokens[self.at]
        self.at += 1
        return token

    def expect(self, value: str) -> Token:
        token = self.take()
        if token.value != value:
            raise Unsupported(f"expected {value!r}, found {token.value!r} at {token.start}")
        return token

    def name(self) -> str:
        return decode_name(self.take().value)

    def number(self) -> int:
        lit = parse_literal(self.take())
        if lit.kind != "integer" or lit.value < 0:
            raise Unsupported("nonconstant bus bound")
        if lit.value > MAX_BUS_INDEX:
            raise Unsupported("bus index cap exceeded")
        return int(lit.value)

    def balanced(self, open_token: str, close_token: str) -> list[Token]:
        self.expect(open_token)
        start = self.at
        depth = 1
        while depth:
            token = self.take().value
            if token == open_token:
                depth += 1
            elif token == close_token:
                depth -= 1
        return self.tokens[start:self.at - 1]


def split_top(tokens: list[Token], delimiter: str) -> list[list[Token]]:
    out, start = [], 0
    depth = 0
    for i, token in enumerate(tokens):
        if token.value in ("(", "[", "{"):
            depth += 1
        elif token.value in (")", "]", "}"):
            depth -= 1
        elif token.value == delimiter and depth == 0:
            out.append(tokens[start:i])
            start = i + 1
        if depth < 0:
            raise Unsupported("unbalanced expression")
    if depth:
        raise Unsupported("unbalanced expression")
    out.append(tokens[start:])
    return out


def parse_expr(tokens: list[Token], depth: int = 0) -> object:
    if depth > MAX_EXPRESSION_DEPTH:
        raise Unsupported("expression depth cap exceeded")
    if not tokens:
        return ("open",)
    c = Cursor(tokens)
    if c.peek() == "{":
        parts = split_top(c.balanced("{", "}"), ",")
        if c.peek():
            raise Unsupported("tokens after concatenation")
        return ("concat", tuple(parse_expr(x, depth + 1) for x in parts))
    if c.peek() == "(":
        inside = c.balanced("(", ")")
        if c.peek():
            raise Unsupported("tokens after parenthesized expression")
        return parse_expr(inside, depth + 1)
    token = c.take()
    if token.value.startswith('"') or token.value[0].isdigit() or token.value[0] == "'":
        lit = parse_literal(token)
        if lit.kind != "integer":
            raise Unsupported("string net expression")
        if c.peek():
            raise Unsupported("arithmetic net expression")
        if lit.width is None:
            raise Unsupported("unsized net constant")
        return ("constant", lit.width, lit.value)
    name = decode_name(token.value)
    select = None
    if c.peek() == "[":
        c.take()
        high = c.number()
        if c.peek() == ":":
            c.take()
            low = c.number()
            select = (high, low)
        else:
            select = (high, high)
        c.expect("]")
    if c.peek():
        raise Unsupported("logic/arithmetic net expression")
    return ("net", name, select)


def parse_named_list(tokens: list[Token], *, parameters: bool) -> dict:
    out = {}
    for part in split_top(tokens, ","):
        if not part:
            raise Unsupported("empty named parameter or port entry")
        c = Cursor(part)
        c.expect(".")
        name = c.name()
        inside = c.balanced("(", ")")
        if c.peek() or name in out:
            raise Unsupported(f"duplicate/malformed named {'parameter' if parameters else 'port'} {name}")
        if parameters:
            if len(inside) != 1:
                raise Unsupported(f"nonliteral parameter {name}")
            out[name] = parse_literal(inside[0])
        else:
            out[name] = parse_expr(inside)
    return out


def parse_range(c: Cursor) -> list[int] | None:
    if c.peek() != "[":
        return None
    c.take()
    high = c.number()
    c.expect(":")
    low = c.number()
    c.expect("]")
    if abs(high - low) + 1 > MAX_NODES:
        raise Unsupported("bus width cap exceeded")
    step = -1 if high >= low else 1
    return list(range(high, low + step, step))


def declaration(c: Cursor, module: Module, first: str) -> None:
    if first in ("reg", "logic"):
        raise Unsupported("variable declaration unsupported")
    direction = first if first in ("input", "output", "inout") else None
    while c.peek() in ("wire", "reg", "tri", "signed", "logic"):
        qualifier = c.take().value
        if qualifier in ("reg", "logic"):
            raise Unsupported("variable declaration unsupported")
    indices = parse_range(c)
    while True:
        name = c.name()
        if direction:
            if name in module.directions and module.directions[name] != direction:
                raise Unsupported(f"conflicting direction {name}")
            module.directions[name] = direction
            if indices is not None:
                module.vector_ports.add(name)
        if indices is not None:
            if name in module.ranges and module.ranges[name] != indices:
                raise Unsupported(f"conflicting bus width {name}")
            module.ranges[name] = indices
        else:
            module.ranges.setdefault(name, [0])
        if c.peek() == "=":
            c.take()
            expr_tokens = []
            while c.peek() not in (",", ";"):
                expr_tokens.append(c.take())
            module.assigns.append((("net", name, None), parse_expr(expr_tokens)))
        if c.peek() != ",":
            break
        c.take()
    c.expect(";")


def parse_module(c: Cursor) -> Module:
    c.expect("module")
    module = Module(c.name())
    if c.peek() == "#":
        c.take()
        # Parameterized module definitions need elaboration. Reject them until
        # an exact export demonstrates a supported specialization.
        raise Unsupported(f"parameterized module definition {module.name}")
    header = c.balanced("(", ")")
    inherited_direction = None
    inherited_indices = None
    for part in split_top(header, ","):
        if not part:
            continue
        values = [x.value for x in part]
        if values[0] in ("input", "output", "inout"):
            inherited_direction = values[0]
            inherited_indices = None
            values = values[1:]
        if "reg" in values or "logic" in values:
            raise Unsupported("variable port declaration unsupported")
        values = [x for x in values if x not in ("wire", "tri", "signed")]
        index = None
        if values and values[0] == "[":
            sub = Cursor([Token(x, 0, 0) for x in values])
            index = parse_range(sub)
            values = values[sub.at:]
            inherited_indices = index
        elif inherited_direction:
            index = inherited_indices
        if len(values) != 1:
            raise Unsupported(f"unsupported module port header {values}")
        name = decode_name(values[0])
        if name in module.header_ports:
            raise Unsupported(f"duplicate module port {name}")
        module.header_ports.append(name)
        if inherited_direction:
            module.directions[name] = inherited_direction
            module.ranges[name] = index if index is not None else [0]
            if index is not None:
                module.vector_ports.add(name)
    c.expect(";")
    while c.peek() != "endmodule":
        token = c.take()
        key = token.value
        if key in ("input", "output", "inout", "wire", "reg", "tri", "logic"):
            declaration(c, module, key)
        elif key == "assign":
            lhs = []
            while c.peek() != "=":
                lhs.append(c.take())
            c.take()
            rhs = []
            while c.peek() != ";":
                rhs.append(c.take())
            c.take()
            module.assigns.append((parse_expr(lhs), parse_expr(rhs)))
        elif key in ("parameter", "localparam"):
            raise Unsupported(f"module parameter declaration in {module.name}")
        else:
            reference = decode_name(key)
            parameters = {}
            if c.peek() == "#":
                c.take()
                parameters = parse_named_list(c.balanced("(", ")"), parameters=True)
            while True:
                name = c.name()
                ports = parse_named_list(c.balanced("(", ")"), parameters=False)
                if any(x.name == name for x in module.instances):
                    raise Unsupported(f"duplicate instance {module.name}/{name}")
                if len(module.instances) >= MAX_INSTANCE_DECLARATIONS:
                    raise Unsupported("instance declaration cap exceeded")
                module.instances.append(Instance(reference, name, parameters, ports))
                if c.peek() != ",":
                    break
                c.take()
            c.expect(";")
    c.take()
    return module


def parse_text(source: str) -> dict[str, Module]:
    c = Cursor(lex(source))
    modules = {}
    while c.peek():
        module = parse_module(c)
        if module.name in modules or len(modules) >= MAX_MODULES:
            raise Unsupported(f"duplicate or excess module {module.name}")
        modules[module.name] = module
    if not modules:
        raise Unsupported("no module definitions")
    return modules


class Components:
    def __init__(self):
        self.parent: dict[str, str] = {}
        self.constant: dict[str, int] = {}
        self.edges = 0

    def add(self, node: str, constant: int | None = None) -> str:
        if node not in self.parent:
            if len(self.parent) >= MAX_NODES:
                raise Unsupported("expanded node cap exceeded")
            self.parent[node] = node
        if constant is not None:
            root = self.find(node)
            if root in self.constant and self.constant[root] != constant:
                raise Unsupported("short between distinct constants")
            self.constant[root] = constant
        return node

    def find(self, node: str) -> str:
        if node not in self.parent:
            self.add(node)
        path = []
        root = node
        while self.parent[root] != root:
            path.append(root)
            root = self.parent[root]
        for child in path:
            self.parent[child] = root
        return root

    def union(self, left: str, right: str) -> None:
        self.edges += 1
        if self.edges > MAX_EDGES:
            raise Unsupported("expanded edge cap exceeded")
        a, b = self.find(left), self.find(right)
        if a == b:
            return
        av, bv = self.constant.get(a), self.constant.get(b)
        if av is not None and bv is not None and av != bv:
            raise Unsupported("conflicting constant aliases")
        self.parent[b] = a
        self.constant.pop(b, None)
        if av is None and bv is not None:
            self.constant[a] = bv


class Expanded:
    def __init__(self, modules: dict[str, Module], primitive_refs: set[str], bank: str):
        self.modules = modules
        self.primitive_refs = primitive_refs
        self.bank = bank
        self.components = Components()
        self.primitives: dict[str, Primitive] = {}
        self.hierarchy: dict[str, str] = {}
        self.boundaries: dict[str, str] = {}
        self.top_module: str | None = None
        self.expanded_instances = 0
        referenced = {inst.reference for mod in modules.values() for inst in mod.instances
                      if inst.reference in modules}
        roots = set(modules) - referenced
        if len(roots) != 1:
            raise Unsupported(f"ambiguous export top modules: {sorted(roots)}")
        self.top_module = next(iter(roots))
        self.expand(self.top_module, bank, ())

    def bits(self, mod: Module, path: str, expr: object,
             depth: int = 0) -> list[str] | None:
        if depth > MAX_EXPRESSION_DEPTH:
            raise Unsupported("expression expansion depth cap exceeded")
        kind = expr[0]
        if kind == "open":
            return None
        if kind == "concat":
            parts = [self.bits(mod, path, part, depth + 1) for part in expr[1]]
            if any(part is None for part in parts):
                raise Unsupported("open net inside concatenation")
            return [bit for part in parts for bit in part]
        if kind == "constant":
            width, value = expr[1:]
            if width <= 0 or width > MAX_LITERAL_BITS:
                raise Unsupported("literal bit width cap exceeded before expansion")
            bits = []
            for index in range(width - 1, -1, -1):
                node = f"{path}/$literal_{len(self.components.parent)}_{index}"
                bits.append(self.components.add(node, (value >> index) & 1))
            return bits
        if kind != "net":
            raise Unsupported("unknown expression type")
        name, selection = expr[1:]
        if name not in mod.ranges:
            raise Unsupported(f"implicit or undeclared net {path}/{name}")
        indices = mod.ranges[name]
        if selection is not None:
            hi, lo = selection
            if abs(hi - lo) + 1 > MAX_NODES:
                raise Unsupported("selected range cap exceeded before expansion")
            if hi not in indices or lo not in indices:
                raise Unsupported(f"out-of-range select {path}/{name}{selection}")
            step = -1 if hi >= lo else 1
            indices = list(range(hi, lo + step, step))
        return [self.components.add(f"{path}/{name}[{index}]") for index in indices]

    def expand(self, module_name: str, path: str, stack: tuple[str, ...]) -> None:
        if len(stack) > MAX_HIERARCHY_DEPTH:
            raise Unsupported("expanded hierarchy depth cap exceeded")
        if module_name in stack:
            raise Unsupported(f"recursive module hierarchy {stack + (module_name,)}")
        if path in self.hierarchy:
            raise Unsupported(f"duplicate expanded module path {path}")
        if len(self.hierarchy) >= MAX_HIERARCHY_INSTANCES:
            raise Unsupported("expanded hierarchy instance cap exceeded")
        self.hierarchy[path] = module_name
        mod = self.modules[module_name]
        for port in mod.header_ports:
            if port not in mod.directions or port not in mod.ranges:
                raise Unsupported(f"undeclared module port {module_name}/{port}")
            if path == self.bank:
                for index in mod.ranges[port]:
                    node = self.components.add(f"{path}/{port}[{index}]")
                    self.boundaries[f"{port}[{index}]"] = node
        for left, right in mod.assigns:
            lhs, rhs = self.bits(mod, path, left), self.bits(mod, path, right)
            if lhs is None or rhs is None or len(lhs) != len(rhs):
                raise Unsupported(f"non-alias assign in {path}")
            for a, b in zip(lhs, rhs):
                self.components.union(a, b)
        for instance in mod.instances:
            if self.expanded_instances >= MAX_HIERARCHY_INSTANCES:
                raise Unsupported("expanded hierarchy instance cap exceeded")
            self.expanded_instances += 1
            child_path = f"{path}/{instance.name}"
            if instance.reference in self.primitive_refs:
                if child_path in self.primitives:
                    raise Unsupported(f"duplicate primitive {child_path}")
                if len(self.primitives) >= MAX_PRIMITIVES:
                    raise Unsupported("primitive expansion cap exceeded")
                ports = {name: self.bits(mod, path, expr)
                         for name, expr in instance.ports.items()}
                if instance.reference in ("VCC", "GND"):
                    pin = "P" if instance.reference == "VCC" else "G"
                    if pin not in ports or ports[pin] is None or len(ports[pin]) != 1:
                        raise Unsupported(f"malformed constant primitive {child_path}")
                    self.components.add(ports[pin][0], int(instance.reference == "VCC"))
                self.primitives[child_path] = Primitive(
                    child_path, instance.reference, instance.parameters, ports,
                    module_name, instance.name)
            elif instance.reference in self.modules:
                if instance.parameters:
                    raise Unsupported(f"unsupported module parameter override {child_path}")
                child = self.modules[instance.reference]
                if set(instance.ports) != set(child.header_ports):
                    raise Unsupported(f"missing or extra child ports {child_path}")
                self.expand(instance.reference, child_path, stack + (module_name,))
                for port, expr in instance.ports.items():
                    actual = self.bits(mod, path, expr)
                    formal = self.bits(child, child_path, ("net", port, None))
                    if actual is None or formal is None or len(actual) != len(formal):
                        raise Unsupported(f"child port width mismatch {child_path}/{port}")
                    for a, b in zip(actual, formal):
                        self.components.union(a, b)
            else:
                raise Unsupported(f"unknown primitive/module {child_path}:{instance.reference}")


def read_export(path: Path, primitive_refs: set[str], bank: str) -> Expanded:
    if path.stat().st_size > MAX_FILE_BYTES:
        raise Unsupported(f"functional export exceeds cap: {path}")
    return Expanded(parse_text(path.read_text(encoding="ascii")), primitive_refs, bank)
