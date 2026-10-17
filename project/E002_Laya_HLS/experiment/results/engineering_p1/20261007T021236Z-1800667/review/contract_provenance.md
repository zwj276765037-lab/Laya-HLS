# P1 数值合同身份的审核补存证据（2026-10-07）

本文件和[numeric_contract_preimage.txt](numeric_contract_preimage.txt)由GPT-6 Astra（`gpt-6-astra`，`xhigh`）在最终审核时补存，并非原运行器自动产生的文件。保存发生于`hardware_agent/task.md`追加§11.8之前；当时当前合同重算值与本次原始[fixture报告](../fixture/numeric_fixture_report.json)的`numeric_contract_sha256`完全相同。原运行报告、候选输出、源码及运行日志未因该补存而改写。

运行器当时的实际定义为：用Python `read_text()`读取`hardware_agent/task.md`，取首次`"## 11. "`之后直至文件末尾的字符串，前接`"P1 Q8-F R0\n"`，再以UTF-8编码并计算SHA-256。`numeric_contract_preimage.txt`保存的正是这一完整字节序列，包括原空白和末尾换行，不能先规范化Markdown或删除前缀再复算。

| 身份 | 保存值 |
| --- | --- |
| 精确前像大小 | 19294 bytes |
| 精确前像SHA-256 | `41da96018781616d7f5fdf250ab814a6f262dbd7cc8a80e60738c78cb1aa93fb` |
| 报告中的实验numeric tag | `41da96018781616d7f5fdf250ab814a6` |
| 追加审核前完整task.md SHA-256 | `80f92d32b4c9ee5b8287db385f08b2cc07c67d062025d6412215b9d2cf41e8bc` |
| 对应合同范围 | task.md §11正文及§11.1–§11.7，包含§11.2.1所有权澄清 |

在本目录执行`sha256sum numeric_contract_preimage.txt`即可独立复算历史报告中的数值合同身份。随后追加的§11.8只是审核结果，不改变本轮数值、接口或验收规则；当前task全文因此不再是本次运行的历史哈希前像。运行器维持原实现，未来运行将依据运行当时的task文本产生自己的实验身份，不宣称纯文档增补前后tag不变。本次没有为这项证据补存重跑或替换已验数值结果。
