# Model policy

Desired settings are not proof of actual runtime settings.
Normalize the latest user instruction into configuration, clearing conflicting more-specific overrides when needed.
Record actual runtime settings only from runtime evidence; never silently substitute a model.

<!-- research-agent:desired-models:begin -->
## Desired model configuration

These are requested launch settings; actual runtime remains unverified.
Precedence: built-in role fallback → project → explicit role → small mission → agent → current launch override.

| Scope | Identity | Desired model | Reasoning effort |
|---|---|---|---|
| built-in fallback | controller | gpt-6-astra | xhigh |
| built-in fallback | research | gpt-6-astra | xhigh |
| built-in fallback | engineering | gpt-6-sol | max |
| role | controller | gpt-6-astra | xhigh |
| role | engineering | gpt-6.1-sol | xhigh |
| role | research | gpt-6-astra | xhigh |
| agent | A007 | gpt-6.1-sol | xhigh |
| agent | A008 | gpt-6.1-sol | xhigh |
| agent | A011 | gpt-6-astra | xhigh |
| agent | A012 | gpt-6.1-sol | xhigh |
| agent | A013 | gpt-6.1-sol | xhigh |

Normalize each new user instruction into configuration and update conflicting specific overrides when needed. Files do not change already-running sessions.
<!-- research-agent:desired-models:end -->

## 当前用户执行政策

工程使用GPT-6.1 Sol/xhigh连续实现、编译、仿真、修复；GPT-6 Astra/xhigh仅在实际综合结果后集中评判与改进。取消逐轮用户审核；不把模型登记当实际运行。未定义合同的实质变更不能由普通修复偷偷替代。角色策略由models.json解析；真实启动后单独记录actual_model/effort及配置证据。
