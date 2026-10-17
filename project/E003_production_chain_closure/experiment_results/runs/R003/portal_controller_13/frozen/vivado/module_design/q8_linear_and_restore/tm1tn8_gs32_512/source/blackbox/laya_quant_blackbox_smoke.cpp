#include "laya_quant_group_service.h"
void laya_quant_blackbox_smoke(const uint64_t input[31], uint64_t output[23]) {
  uint64_t echo0=0;
  uint64_t echo1=0;
  uint64_t echo2=0;
  uint64_t echo3=0;
  uint64_t echo4=0;
  uint64_t echo5=0;
  uint64_t echo6=0;
  uint64_t echo7=0;
  uint64_t echo8=0;
  uint64_t echo9=0;
  uint64_t echo10=0;
  uint64_t echo11=0;
  uint64_t echo12=0;
  uint64_t echo13=0;
  uint64_t q0=0;
  uint64_t q1=0;
  uint64_t q2=0;
  uint64_t q3=0;
  uint32_t scale=0;
  uint32_t d_full=0;
  uint32_t reciprocal=0;
  uint32_t status=0;
  uint32_t bad_col=0;
  laya_quant_group_service(input[0],
    input[1],
    input[2],
    input[3],
    input[4],
    input[5],
    input[6],
    input[7],
    input[8],
    input[9],
    input[10],
    input[11],
    input[12],
    input[13],
    input[14],
    input[15],
    input[16],
    input[17],
    input[18],
    input[19],
    input[20],
    input[21],
    input[22],
    input[23],
    input[24],
    input[25],
    input[26],
    input[27],
    input[28],
    input[29],
    input[30],
    echo0,
    echo1,
    echo2,
    echo3,
    echo4,
    echo5,
    echo6,
    echo7,
    echo8,
    echo9,
    echo10,
    echo11,
    echo12,
    echo13,
    q0,
    q1,
    q2,
    q3,
    scale,
    d_full,
    reciprocal,
    status,
    bad_col);
  output[0]=echo0;
  output[1]=echo1;
  output[2]=echo2;
  output[3]=echo3;
  output[4]=echo4;
  output[5]=echo5;
  output[6]=echo6;
  output[7]=echo7;
  output[8]=echo8;
  output[9]=echo9;
  output[10]=echo10;
  output[11]=echo11;
  output[12]=echo12;
  output[13]=echo13;
  output[14]=q0;
  output[15]=q1;
  output[16]=q2;
  output[17]=q3;
  output[18]=scale;
  output[19]=d_full;
  output[20]=reciprocal;
  output[21]=status;
  output[22]=bad_col;
}
