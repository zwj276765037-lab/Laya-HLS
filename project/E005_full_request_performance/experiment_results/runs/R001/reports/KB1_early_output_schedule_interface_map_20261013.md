# KB1提前完整输出候选的现有接口映射

只读当前冻结KB1模块，无新DUT/仿真。G=82、T=128、10496stripes。外层resident每组读一次A，顺序跑该组128个W tile，再进入下一组；`logical_sequence=group*T+tile`，当前A实际读82次。首AW比cfg晚11248cycles。结果较晚形成是顺序事实，尚未证明新顺序的实际性能。

前端同步PS模块还要求`issue_sequence==next_sequence && issue_group==next_group && issue_tile==next_tile`，并在每个tile之后才推进组号。因此单改外层循环会被当前前端判协议错误；候选须同步改前端的期望顺序，同时保留原完整`group*T+tile`逻辑序号/各tile按group0→81的累加顺序，不将新执行位置冒充原键。A缓存read_ok只按真实slot/epoch/identity/group范围核，W缓存read_ok也核真实slot/epoch/身份/地址范围；所读代码未见只允许单调group的门，但新访问次序仍要动态验证全部返回绑定和lease。

若按连续B个tile为一块、块内仍逐group，A读取次数为82×ceil(128/B)：B=128时82、64时164、32时328、16时656。额外A请求/返回和重读本地缓存的代价必须计入，不能只看首输出提前。最早完成第一块需要82×B个stripe的顺序工作量只是结构式，不是预测周期。输出adapter按tile/row退休，递增tile块理论可保持其顺序，但bias、前端credit/trace、writer末B及完整gold仍需实际动态证据。

[字段与冻结SHA](KB1_early_output_schedule_interface_map_20261013.json)。
