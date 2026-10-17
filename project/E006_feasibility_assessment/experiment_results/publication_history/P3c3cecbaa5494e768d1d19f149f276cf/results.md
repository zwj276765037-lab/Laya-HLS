# E006 关键结果摘要

AT065首full Down准入X FAIL 2080.617893s；AT070次full W装载语义停滞716.009461s，无完整链PASS。AT071同top短W探针在3000cycle FAIL：q0/q1/scale R=0/64/0，q0第二AR后RREADY=0，时钟仍运行；guard15.236713s，日志Fatal，child0非PASS。AT072只修TB W/AUX响应模型posedge竞争，真实同top短探针见q0第二AR106、第二段首R107，q0/q1/scale R=128/128/64、AUX末R33，cycle187 PASS，guard6.771937s。AT073正常TB静态编译/展开child0，新冷LN前缀cycle5224真1AR/64R通过，22.688626s；原236项及候选22项preflight ACCEPT。规划520000cycle按慢速172.487cycle/s和10%余量为3316.188s，小于3600s，只是成本准入。AT073最后一次正常full已真实启动，当前无终态；M005 full次数已3/3，最终整链gold与物理结果仍待测。详见 project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_AT071_AT073_W_phase_fix_progress_20261014.md。


---
Published: 2026-10-14T04:12:55.817519+00:00
Publication: P05adacccbd784a2e8f58004abe5c219f
