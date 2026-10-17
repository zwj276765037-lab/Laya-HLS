# M005 请求身份补充

接 `m005-engineering-capacity-answer-20261014`：M005 指定的 `project/E002_Laya_HLS/experiment/build/current-production-requests-v2-20261011/B1_from_b0_S128.request.bin` 为1152B，SHA256 `87fc82b1d455ed27ad6bfced11322ed6ef2a6a6a5c61bc80946f7cbe6ff07cbe`。只读解析其第4个ABI payload的16B `marker_mask` 为 `[1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0]`，与前答的v4帧相同：16个 scorer 槽、2个有效候选、ACT 每 batch 一行。v4 与 current-production-v2 的整帧 SHA 不同，后续以各自 manifest/数值身份使用，不互换帧。
