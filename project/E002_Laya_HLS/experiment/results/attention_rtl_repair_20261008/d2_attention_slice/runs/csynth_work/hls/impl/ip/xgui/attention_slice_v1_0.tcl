# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set group_0 [ipgui::add_group $IPINST -name "group 0" -parent ${Page_0} -display_name {AXI4 Master Interface m_axi_fixture}]
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_ENABLE_ID_PORTS" -parent ${group_0}
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_ID_WIDTH" -parent ${group_0}
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_DATA_WIDTH" -parent ${group_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_ENABLE_USER_PORTS" -parent ${group_0}
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_AWUSER_WIDTH" -parent ${group_0}
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_WUSER_WIDTH" -parent ${group_0}
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_BUSER_WIDTH" -parent ${group_0}
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_ARUSER_WIDTH" -parent ${group_0}
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_RUSER_WIDTH" -parent ${group_0}
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_USER_VALUE" -parent ${group_0}
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_PROT_VALUE" -parent ${group_0}
  ipgui::add_param $IPINST -name "C_M_AXI_FIXTURE_CACHE_VALUE" -parent ${group_0}

  #Adding Group
  set group_1 [ipgui::add_group $IPINST -name "group 1" -parent ${Page_0} -display_name {AXI4 Master Interface m_axi_io}]
  ipgui::add_param $IPINST -name "C_M_AXI_IO_ENABLE_ID_PORTS" -parent ${group_1}
  ipgui::add_param $IPINST -name "C_M_AXI_IO_ID_WIDTH" -parent ${group_1}
  ipgui::add_param $IPINST -name "C_M_AXI_IO_DATA_WIDTH" -parent ${group_1} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_AXI_IO_ENABLE_USER_PORTS" -parent ${group_1}
  ipgui::add_param $IPINST -name "C_M_AXI_IO_AWUSER_WIDTH" -parent ${group_1}
  ipgui::add_param $IPINST -name "C_M_AXI_IO_WUSER_WIDTH" -parent ${group_1}
  ipgui::add_param $IPINST -name "C_M_AXI_IO_BUSER_WIDTH" -parent ${group_1}
  ipgui::add_param $IPINST -name "C_M_AXI_IO_ARUSER_WIDTH" -parent ${group_1}
  ipgui::add_param $IPINST -name "C_M_AXI_IO_RUSER_WIDTH" -parent ${group_1}
  ipgui::add_param $IPINST -name "C_M_AXI_IO_USER_VALUE" -parent ${group_1}
  ipgui::add_param $IPINST -name "C_M_AXI_IO_PROT_VALUE" -parent ${group_1}
  ipgui::add_param $IPINST -name "C_M_AXI_IO_CACHE_VALUE" -parent ${group_1}

  #Adding Group
  set group_2 [ipgui::add_group $IPINST -name "group 2" -parent ${Page_0} -display_name {AXI4 Master Interface m_axi_aux}]
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_ENABLE_ID_PORTS" -parent ${group_2}
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_ID_WIDTH" -parent ${group_2}
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_DATA_WIDTH" -parent ${group_2} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_ENABLE_USER_PORTS" -parent ${group_2}
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_AWUSER_WIDTH" -parent ${group_2}
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_WUSER_WIDTH" -parent ${group_2}
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_BUSER_WIDTH" -parent ${group_2}
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_ARUSER_WIDTH" -parent ${group_2}
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_RUSER_WIDTH" -parent ${group_2}
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_USER_VALUE" -parent ${group_2}
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_PROT_VALUE" -parent ${group_2}
  ipgui::add_param $IPINST -name "C_M_AXI_AUX_CACHE_VALUE" -parent ${group_2}

  #Adding Group
  set group_3 [ipgui::add_group $IPINST -name "group 3" -parent ${Page_0} -display_name {AXI4 Master Interface m_axi_qkv0}]
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_ENABLE_ID_PORTS" -parent ${group_3}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_ID_WIDTH" -parent ${group_3}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_DATA_WIDTH" -parent ${group_3} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_ENABLE_USER_PORTS" -parent ${group_3}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_AWUSER_WIDTH" -parent ${group_3}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_WUSER_WIDTH" -parent ${group_3}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_BUSER_WIDTH" -parent ${group_3}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_ARUSER_WIDTH" -parent ${group_3}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_RUSER_WIDTH" -parent ${group_3}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_USER_VALUE" -parent ${group_3}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_PROT_VALUE" -parent ${group_3}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV0_CACHE_VALUE" -parent ${group_3}

  #Adding Group
  set group_4 [ipgui::add_group $IPINST -name "group 4" -parent ${Page_0} -display_name {AXI4 Master Interface m_axi_qkv1}]
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_ENABLE_ID_PORTS" -parent ${group_4}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_ID_WIDTH" -parent ${group_4}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_DATA_WIDTH" -parent ${group_4} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_ENABLE_USER_PORTS" -parent ${group_4}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_AWUSER_WIDTH" -parent ${group_4}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_WUSER_WIDTH" -parent ${group_4}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_BUSER_WIDTH" -parent ${group_4}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_ARUSER_WIDTH" -parent ${group_4}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_RUSER_WIDTH" -parent ${group_4}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_USER_VALUE" -parent ${group_4}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_PROT_VALUE" -parent ${group_4}
  ipgui::add_param $IPINST -name "C_M_AXI_QKV1_CACHE_VALUE" -parent ${group_4}

  #Adding Group
  set group_5 [ipgui::add_group $IPINST -name "group 5" -parent ${Page_0} -display_name {AXI4 Master Interface m_axi_att_out}]
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_ENABLE_ID_PORTS" -parent ${group_5}
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_ID_WIDTH" -parent ${group_5}
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_DATA_WIDTH" -parent ${group_5} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_ENABLE_USER_PORTS" -parent ${group_5}
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_AWUSER_WIDTH" -parent ${group_5}
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_WUSER_WIDTH" -parent ${group_5}
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_BUSER_WIDTH" -parent ${group_5}
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_ARUSER_WIDTH" -parent ${group_5}
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_RUSER_WIDTH" -parent ${group_5}
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_USER_VALUE" -parent ${group_5}
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_PROT_VALUE" -parent ${group_5}
  ipgui::add_param $IPINST -name "C_M_AXI_ATT_OUT_CACHE_VALUE" -parent ${group_5}

  #Adding Group
  set group_6 [ipgui::add_group $IPINST -name "group 6" -parent ${Page_0} -display_name {AXI4 Master Interface m_axi_observed}]
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_ENABLE_ID_PORTS" -parent ${group_6}
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_ID_WIDTH" -parent ${group_6}
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_DATA_WIDTH" -parent ${group_6} -widget comboBox
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_ENABLE_USER_PORTS" -parent ${group_6}
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_AWUSER_WIDTH" -parent ${group_6}
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_WUSER_WIDTH" -parent ${group_6}
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_BUSER_WIDTH" -parent ${group_6}
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_ARUSER_WIDTH" -parent ${group_6}
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_RUSER_WIDTH" -parent ${group_6}
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_USER_VALUE" -parent ${group_6}
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_PROT_VALUE" -parent ${group_6}
  ipgui::add_param $IPINST -name "C_M_AXI_OBSERVED_CACHE_VALUE" -parent ${group_6}



}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_FIXTURE_ENABLE_ID_PORTS } {
	# Procedure called to update C_M_AXI_FIXTURE_ENABLE_ID_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_FIXTURE_ENABLE_ID_PORTS } {
	# Procedure called to validate C_M_AXI_FIXTURE_ENABLE_ID_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_ID_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_ID_WIDTH } {
	# Procedure called to update C_M_AXI_FIXTURE_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_ID_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_ID_WIDTH } {
	# Procedure called to validate C_M_AXI_FIXTURE_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_DATA_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_FIXTURE_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_DATA_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_FIXTURE_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_FIXTURE_ENABLE_USER_PORTS } {
	# Procedure called to update C_M_AXI_FIXTURE_ENABLE_USER_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_FIXTURE_ENABLE_USER_PORTS } {
	# Procedure called to validate C_M_AXI_FIXTURE_ENABLE_USER_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_AWUSER_WIDTH } {
	# Procedure called to update C_M_AXI_FIXTURE_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_AWUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_FIXTURE_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_WUSER_WIDTH } {
	# Procedure called to update C_M_AXI_FIXTURE_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_WUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_FIXTURE_WUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_BUSER_WIDTH } {
	# Procedure called to update C_M_AXI_FIXTURE_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_BUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_FIXTURE_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_ARUSER_WIDTH } {
	# Procedure called to update C_M_AXI_FIXTURE_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_ARUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_FIXTURE_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_RUSER_WIDTH } {
	# Procedure called to update C_M_AXI_FIXTURE_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_FIXTURE_RUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_FIXTURE_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_USER_VALUE { PARAM_VALUE.C_M_AXI_FIXTURE_USER_VALUE } {
	# Procedure called to update C_M_AXI_FIXTURE_USER_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_USER_VALUE { PARAM_VALUE.C_M_AXI_FIXTURE_USER_VALUE } {
	# Procedure called to validate C_M_AXI_FIXTURE_USER_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_PROT_VALUE { PARAM_VALUE.C_M_AXI_FIXTURE_PROT_VALUE } {
	# Procedure called to update C_M_AXI_FIXTURE_PROT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_PROT_VALUE { PARAM_VALUE.C_M_AXI_FIXTURE_PROT_VALUE } {
	# Procedure called to validate C_M_AXI_FIXTURE_PROT_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_FIXTURE_CACHE_VALUE { PARAM_VALUE.C_M_AXI_FIXTURE_CACHE_VALUE } {
	# Procedure called to update C_M_AXI_FIXTURE_CACHE_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_FIXTURE_CACHE_VALUE { PARAM_VALUE.C_M_AXI_FIXTURE_CACHE_VALUE } {
	# Procedure called to validate C_M_AXI_FIXTURE_CACHE_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_IO_ENABLE_ID_PORTS } {
	# Procedure called to update C_M_AXI_IO_ENABLE_ID_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_IO_ENABLE_ID_PORTS } {
	# Procedure called to validate C_M_AXI_IO_ENABLE_ID_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_ID_WIDTH { PARAM_VALUE.C_M_AXI_IO_ID_WIDTH } {
	# Procedure called to update C_M_AXI_IO_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_ID_WIDTH { PARAM_VALUE.C_M_AXI_IO_ID_WIDTH } {
	# Procedure called to validate C_M_AXI_IO_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_DATA_WIDTH { PARAM_VALUE.C_M_AXI_IO_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_IO_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_DATA_WIDTH { PARAM_VALUE.C_M_AXI_IO_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_IO_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_IO_ENABLE_USER_PORTS } {
	# Procedure called to update C_M_AXI_IO_ENABLE_USER_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_IO_ENABLE_USER_PORTS } {
	# Procedure called to validate C_M_AXI_IO_ENABLE_USER_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_IO_AWUSER_WIDTH } {
	# Procedure called to update C_M_AXI_IO_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_IO_AWUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_IO_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_IO_WUSER_WIDTH } {
	# Procedure called to update C_M_AXI_IO_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_IO_WUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_IO_WUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_IO_BUSER_WIDTH } {
	# Procedure called to update C_M_AXI_IO_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_IO_BUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_IO_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_IO_ARUSER_WIDTH } {
	# Procedure called to update C_M_AXI_IO_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_IO_ARUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_IO_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_IO_RUSER_WIDTH } {
	# Procedure called to update C_M_AXI_IO_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_IO_RUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_IO_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_USER_VALUE { PARAM_VALUE.C_M_AXI_IO_USER_VALUE } {
	# Procedure called to update C_M_AXI_IO_USER_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_USER_VALUE { PARAM_VALUE.C_M_AXI_IO_USER_VALUE } {
	# Procedure called to validate C_M_AXI_IO_USER_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_PROT_VALUE { PARAM_VALUE.C_M_AXI_IO_PROT_VALUE } {
	# Procedure called to update C_M_AXI_IO_PROT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_PROT_VALUE { PARAM_VALUE.C_M_AXI_IO_PROT_VALUE } {
	# Procedure called to validate C_M_AXI_IO_PROT_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_IO_CACHE_VALUE { PARAM_VALUE.C_M_AXI_IO_CACHE_VALUE } {
	# Procedure called to update C_M_AXI_IO_CACHE_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_IO_CACHE_VALUE { PARAM_VALUE.C_M_AXI_IO_CACHE_VALUE } {
	# Procedure called to validate C_M_AXI_IO_CACHE_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_AUX_ENABLE_ID_PORTS } {
	# Procedure called to update C_M_AXI_AUX_ENABLE_ID_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_AUX_ENABLE_ID_PORTS } {
	# Procedure called to validate C_M_AXI_AUX_ENABLE_ID_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_ID_WIDTH { PARAM_VALUE.C_M_AXI_AUX_ID_WIDTH } {
	# Procedure called to update C_M_AXI_AUX_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_ID_WIDTH { PARAM_VALUE.C_M_AXI_AUX_ID_WIDTH } {
	# Procedure called to validate C_M_AXI_AUX_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_DATA_WIDTH { PARAM_VALUE.C_M_AXI_AUX_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_AUX_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_DATA_WIDTH { PARAM_VALUE.C_M_AXI_AUX_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_AUX_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_AUX_ENABLE_USER_PORTS } {
	# Procedure called to update C_M_AXI_AUX_ENABLE_USER_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_AUX_ENABLE_USER_PORTS } {
	# Procedure called to validate C_M_AXI_AUX_ENABLE_USER_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_AUX_AWUSER_WIDTH } {
	# Procedure called to update C_M_AXI_AUX_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_AUX_AWUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_AUX_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_AUX_WUSER_WIDTH } {
	# Procedure called to update C_M_AXI_AUX_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_AUX_WUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_AUX_WUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_AUX_BUSER_WIDTH } {
	# Procedure called to update C_M_AXI_AUX_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_AUX_BUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_AUX_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_AUX_ARUSER_WIDTH } {
	# Procedure called to update C_M_AXI_AUX_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_AUX_ARUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_AUX_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_AUX_RUSER_WIDTH } {
	# Procedure called to update C_M_AXI_AUX_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_AUX_RUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_AUX_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_USER_VALUE { PARAM_VALUE.C_M_AXI_AUX_USER_VALUE } {
	# Procedure called to update C_M_AXI_AUX_USER_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_USER_VALUE { PARAM_VALUE.C_M_AXI_AUX_USER_VALUE } {
	# Procedure called to validate C_M_AXI_AUX_USER_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_PROT_VALUE { PARAM_VALUE.C_M_AXI_AUX_PROT_VALUE } {
	# Procedure called to update C_M_AXI_AUX_PROT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_PROT_VALUE { PARAM_VALUE.C_M_AXI_AUX_PROT_VALUE } {
	# Procedure called to validate C_M_AXI_AUX_PROT_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_AUX_CACHE_VALUE { PARAM_VALUE.C_M_AXI_AUX_CACHE_VALUE } {
	# Procedure called to update C_M_AXI_AUX_CACHE_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_AUX_CACHE_VALUE { PARAM_VALUE.C_M_AXI_AUX_CACHE_VALUE } {
	# Procedure called to validate C_M_AXI_AUX_CACHE_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_QKV0_ENABLE_ID_PORTS } {
	# Procedure called to update C_M_AXI_QKV0_ENABLE_ID_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_QKV0_ENABLE_ID_PORTS } {
	# Procedure called to validate C_M_AXI_QKV0_ENABLE_ID_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_ID_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_ID_WIDTH } {
	# Procedure called to update C_M_AXI_QKV0_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_ID_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_ID_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV0_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_DATA_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_QKV0_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_DATA_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV0_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_QKV0_ENABLE_USER_PORTS } {
	# Procedure called to update C_M_AXI_QKV0_ENABLE_USER_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_QKV0_ENABLE_USER_PORTS } {
	# Procedure called to validate C_M_AXI_QKV0_ENABLE_USER_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_AWUSER_WIDTH } {
	# Procedure called to update C_M_AXI_QKV0_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_AWUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV0_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_WUSER_WIDTH } {
	# Procedure called to update C_M_AXI_QKV0_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_WUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV0_WUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_BUSER_WIDTH } {
	# Procedure called to update C_M_AXI_QKV0_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_BUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV0_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_ARUSER_WIDTH } {
	# Procedure called to update C_M_AXI_QKV0_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_ARUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV0_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_RUSER_WIDTH } {
	# Procedure called to update C_M_AXI_QKV0_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV0_RUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV0_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_USER_VALUE { PARAM_VALUE.C_M_AXI_QKV0_USER_VALUE } {
	# Procedure called to update C_M_AXI_QKV0_USER_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_USER_VALUE { PARAM_VALUE.C_M_AXI_QKV0_USER_VALUE } {
	# Procedure called to validate C_M_AXI_QKV0_USER_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_PROT_VALUE { PARAM_VALUE.C_M_AXI_QKV0_PROT_VALUE } {
	# Procedure called to update C_M_AXI_QKV0_PROT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_PROT_VALUE { PARAM_VALUE.C_M_AXI_QKV0_PROT_VALUE } {
	# Procedure called to validate C_M_AXI_QKV0_PROT_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV0_CACHE_VALUE { PARAM_VALUE.C_M_AXI_QKV0_CACHE_VALUE } {
	# Procedure called to update C_M_AXI_QKV0_CACHE_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV0_CACHE_VALUE { PARAM_VALUE.C_M_AXI_QKV0_CACHE_VALUE } {
	# Procedure called to validate C_M_AXI_QKV0_CACHE_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_QKV1_ENABLE_ID_PORTS } {
	# Procedure called to update C_M_AXI_QKV1_ENABLE_ID_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_QKV1_ENABLE_ID_PORTS } {
	# Procedure called to validate C_M_AXI_QKV1_ENABLE_ID_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_ID_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_ID_WIDTH } {
	# Procedure called to update C_M_AXI_QKV1_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_ID_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_ID_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV1_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_DATA_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_QKV1_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_DATA_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV1_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_QKV1_ENABLE_USER_PORTS } {
	# Procedure called to update C_M_AXI_QKV1_ENABLE_USER_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_QKV1_ENABLE_USER_PORTS } {
	# Procedure called to validate C_M_AXI_QKV1_ENABLE_USER_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_AWUSER_WIDTH } {
	# Procedure called to update C_M_AXI_QKV1_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_AWUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV1_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_WUSER_WIDTH } {
	# Procedure called to update C_M_AXI_QKV1_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_WUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV1_WUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_BUSER_WIDTH } {
	# Procedure called to update C_M_AXI_QKV1_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_BUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV1_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_ARUSER_WIDTH } {
	# Procedure called to update C_M_AXI_QKV1_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_ARUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV1_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_RUSER_WIDTH } {
	# Procedure called to update C_M_AXI_QKV1_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_QKV1_RUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_QKV1_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_USER_VALUE { PARAM_VALUE.C_M_AXI_QKV1_USER_VALUE } {
	# Procedure called to update C_M_AXI_QKV1_USER_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_USER_VALUE { PARAM_VALUE.C_M_AXI_QKV1_USER_VALUE } {
	# Procedure called to validate C_M_AXI_QKV1_USER_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_PROT_VALUE { PARAM_VALUE.C_M_AXI_QKV1_PROT_VALUE } {
	# Procedure called to update C_M_AXI_QKV1_PROT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_PROT_VALUE { PARAM_VALUE.C_M_AXI_QKV1_PROT_VALUE } {
	# Procedure called to validate C_M_AXI_QKV1_PROT_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_QKV1_CACHE_VALUE { PARAM_VALUE.C_M_AXI_QKV1_CACHE_VALUE } {
	# Procedure called to update C_M_AXI_QKV1_CACHE_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_QKV1_CACHE_VALUE { PARAM_VALUE.C_M_AXI_QKV1_CACHE_VALUE } {
	# Procedure called to validate C_M_AXI_QKV1_CACHE_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_ATT_OUT_ENABLE_ID_PORTS } {
	# Procedure called to update C_M_AXI_ATT_OUT_ENABLE_ID_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_ATT_OUT_ENABLE_ID_PORTS } {
	# Procedure called to validate C_M_AXI_ATT_OUT_ENABLE_ID_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_ID_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_ID_WIDTH } {
	# Procedure called to update C_M_AXI_ATT_OUT_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_ID_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_ID_WIDTH } {
	# Procedure called to validate C_M_AXI_ATT_OUT_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_DATA_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_ATT_OUT_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_DATA_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_ATT_OUT_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_ATT_OUT_ENABLE_USER_PORTS } {
	# Procedure called to update C_M_AXI_ATT_OUT_ENABLE_USER_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_ATT_OUT_ENABLE_USER_PORTS } {
	# Procedure called to validate C_M_AXI_ATT_OUT_ENABLE_USER_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_AWUSER_WIDTH } {
	# Procedure called to update C_M_AXI_ATT_OUT_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_AWUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_ATT_OUT_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_WUSER_WIDTH } {
	# Procedure called to update C_M_AXI_ATT_OUT_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_WUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_ATT_OUT_WUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_BUSER_WIDTH } {
	# Procedure called to update C_M_AXI_ATT_OUT_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_BUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_ATT_OUT_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_ARUSER_WIDTH } {
	# Procedure called to update C_M_AXI_ATT_OUT_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_ARUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_ATT_OUT_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_RUSER_WIDTH } {
	# Procedure called to update C_M_AXI_ATT_OUT_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_ATT_OUT_RUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_ATT_OUT_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_USER_VALUE { PARAM_VALUE.C_M_AXI_ATT_OUT_USER_VALUE } {
	# Procedure called to update C_M_AXI_ATT_OUT_USER_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_USER_VALUE { PARAM_VALUE.C_M_AXI_ATT_OUT_USER_VALUE } {
	# Procedure called to validate C_M_AXI_ATT_OUT_USER_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_PROT_VALUE { PARAM_VALUE.C_M_AXI_ATT_OUT_PROT_VALUE } {
	# Procedure called to update C_M_AXI_ATT_OUT_PROT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_PROT_VALUE { PARAM_VALUE.C_M_AXI_ATT_OUT_PROT_VALUE } {
	# Procedure called to validate C_M_AXI_ATT_OUT_PROT_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ATT_OUT_CACHE_VALUE { PARAM_VALUE.C_M_AXI_ATT_OUT_CACHE_VALUE } {
	# Procedure called to update C_M_AXI_ATT_OUT_CACHE_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ATT_OUT_CACHE_VALUE { PARAM_VALUE.C_M_AXI_ATT_OUT_CACHE_VALUE } {
	# Procedure called to validate C_M_AXI_ATT_OUT_CACHE_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_OBSERVED_ENABLE_ID_PORTS } {
	# Procedure called to update C_M_AXI_OBSERVED_ENABLE_ID_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_ENABLE_ID_PORTS { PARAM_VALUE.C_M_AXI_OBSERVED_ENABLE_ID_PORTS } {
	# Procedure called to validate C_M_AXI_OBSERVED_ENABLE_ID_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_ID_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_ID_WIDTH } {
	# Procedure called to update C_M_AXI_OBSERVED_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_ID_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_ID_WIDTH } {
	# Procedure called to validate C_M_AXI_OBSERVED_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_DATA_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_OBSERVED_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_DATA_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_OBSERVED_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_OBSERVED_ENABLE_USER_PORTS } {
	# Procedure called to update C_M_AXI_OBSERVED_ENABLE_USER_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_ENABLE_USER_PORTS { PARAM_VALUE.C_M_AXI_OBSERVED_ENABLE_USER_PORTS } {
	# Procedure called to validate C_M_AXI_OBSERVED_ENABLE_USER_PORTS
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_AWUSER_WIDTH } {
	# Procedure called to update C_M_AXI_OBSERVED_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_AWUSER_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_AWUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_OBSERVED_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_WUSER_WIDTH } {
	# Procedure called to update C_M_AXI_OBSERVED_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_WUSER_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_WUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_OBSERVED_WUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_BUSER_WIDTH } {
	# Procedure called to update C_M_AXI_OBSERVED_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_BUSER_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_BUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_OBSERVED_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_ARUSER_WIDTH } {
	# Procedure called to update C_M_AXI_OBSERVED_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_ARUSER_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_ARUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_OBSERVED_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_RUSER_WIDTH } {
	# Procedure called to update C_M_AXI_OBSERVED_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_RUSER_WIDTH { PARAM_VALUE.C_M_AXI_OBSERVED_RUSER_WIDTH } {
	# Procedure called to validate C_M_AXI_OBSERVED_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_USER_VALUE { PARAM_VALUE.C_M_AXI_OBSERVED_USER_VALUE } {
	# Procedure called to update C_M_AXI_OBSERVED_USER_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_USER_VALUE { PARAM_VALUE.C_M_AXI_OBSERVED_USER_VALUE } {
	# Procedure called to validate C_M_AXI_OBSERVED_USER_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_PROT_VALUE { PARAM_VALUE.C_M_AXI_OBSERVED_PROT_VALUE } {
	# Procedure called to update C_M_AXI_OBSERVED_PROT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_PROT_VALUE { PARAM_VALUE.C_M_AXI_OBSERVED_PROT_VALUE } {
	# Procedure called to validate C_M_AXI_OBSERVED_PROT_VALUE
	return true
}

proc update_PARAM_VALUE.C_M_AXI_OBSERVED_CACHE_VALUE { PARAM_VALUE.C_M_AXI_OBSERVED_CACHE_VALUE } {
	# Procedure called to update C_M_AXI_OBSERVED_CACHE_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_OBSERVED_CACHE_VALUE { PARAM_VALUE.C_M_AXI_OBSERVED_CACHE_VALUE } {
	# Procedure called to validate C_M_AXI_OBSERVED_CACHE_VALUE
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_CONTROL_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_CONTROL_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "C_S_AXI_CONTROL_ADDR_WIDTH". Setting updated value from the model parameter.
set_property value 4 ${MODELPARAM_VALUE.C_S_AXI_CONTROL_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_CONTROL_R_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_CONTROL_R_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "C_S_AXI_CONTROL_R_ADDR_WIDTH". Setting updated value from the model parameter.
set_property value 7 ${MODELPARAM_VALUE.C_S_AXI_CONTROL_R_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_FIXTURE_ID_WIDTH { MODELPARAM_VALUE.C_M_AXI_FIXTURE_ID_WIDTH PARAM_VALUE.C_M_AXI_FIXTURE_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_FIXTURE_ID_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_FIXTURE_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_FIXTURE_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_FIXTURE_DATA_WIDTH PARAM_VALUE.C_M_AXI_FIXTURE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_FIXTURE_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_FIXTURE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_FIXTURE_AWUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_FIXTURE_AWUSER_WIDTH PARAM_VALUE.C_M_AXI_FIXTURE_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_FIXTURE_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_FIXTURE_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_FIXTURE_ARUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_FIXTURE_ARUSER_WIDTH PARAM_VALUE.C_M_AXI_FIXTURE_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_FIXTURE_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_FIXTURE_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_FIXTURE_WUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_FIXTURE_WUSER_WIDTH PARAM_VALUE.C_M_AXI_FIXTURE_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_FIXTURE_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_FIXTURE_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_FIXTURE_RUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_FIXTURE_RUSER_WIDTH PARAM_VALUE.C_M_AXI_FIXTURE_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_FIXTURE_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_FIXTURE_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_FIXTURE_BUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_FIXTURE_BUSER_WIDTH PARAM_VALUE.C_M_AXI_FIXTURE_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_FIXTURE_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_FIXTURE_BUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_FIXTURE_USER_VALUE { MODELPARAM_VALUE.C_M_AXI_FIXTURE_USER_VALUE PARAM_VALUE.C_M_AXI_FIXTURE_USER_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_FIXTURE_USER_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_FIXTURE_USER_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_FIXTURE_PROT_VALUE { MODELPARAM_VALUE.C_M_AXI_FIXTURE_PROT_VALUE PARAM_VALUE.C_M_AXI_FIXTURE_PROT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_FIXTURE_PROT_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_FIXTURE_PROT_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_FIXTURE_CACHE_VALUE { MODELPARAM_VALUE.C_M_AXI_FIXTURE_CACHE_VALUE PARAM_VALUE.C_M_AXI_FIXTURE_CACHE_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_FIXTURE_CACHE_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_FIXTURE_CACHE_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_IO_ID_WIDTH { MODELPARAM_VALUE.C_M_AXI_IO_ID_WIDTH PARAM_VALUE.C_M_AXI_IO_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_IO_ID_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_IO_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_IO_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_IO_DATA_WIDTH PARAM_VALUE.C_M_AXI_IO_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_IO_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_IO_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_IO_AWUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_IO_AWUSER_WIDTH PARAM_VALUE.C_M_AXI_IO_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_IO_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_IO_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_IO_ARUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_IO_ARUSER_WIDTH PARAM_VALUE.C_M_AXI_IO_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_IO_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_IO_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_IO_WUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_IO_WUSER_WIDTH PARAM_VALUE.C_M_AXI_IO_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_IO_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_IO_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_IO_RUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_IO_RUSER_WIDTH PARAM_VALUE.C_M_AXI_IO_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_IO_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_IO_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_IO_BUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_IO_BUSER_WIDTH PARAM_VALUE.C_M_AXI_IO_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_IO_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_IO_BUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_IO_USER_VALUE { MODELPARAM_VALUE.C_M_AXI_IO_USER_VALUE PARAM_VALUE.C_M_AXI_IO_USER_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_IO_USER_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_IO_USER_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_IO_PROT_VALUE { MODELPARAM_VALUE.C_M_AXI_IO_PROT_VALUE PARAM_VALUE.C_M_AXI_IO_PROT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_IO_PROT_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_IO_PROT_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_IO_CACHE_VALUE { MODELPARAM_VALUE.C_M_AXI_IO_CACHE_VALUE PARAM_VALUE.C_M_AXI_IO_CACHE_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_IO_CACHE_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_IO_CACHE_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AUX_ID_WIDTH { MODELPARAM_VALUE.C_M_AXI_AUX_ID_WIDTH PARAM_VALUE.C_M_AXI_AUX_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AUX_ID_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_AUX_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AUX_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_AUX_DATA_WIDTH PARAM_VALUE.C_M_AXI_AUX_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AUX_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_AUX_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AUX_AWUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_AUX_AWUSER_WIDTH PARAM_VALUE.C_M_AXI_AUX_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AUX_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_AUX_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AUX_ARUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_AUX_ARUSER_WIDTH PARAM_VALUE.C_M_AXI_AUX_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AUX_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_AUX_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AUX_WUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_AUX_WUSER_WIDTH PARAM_VALUE.C_M_AXI_AUX_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AUX_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_AUX_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AUX_RUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_AUX_RUSER_WIDTH PARAM_VALUE.C_M_AXI_AUX_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AUX_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_AUX_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AUX_BUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_AUX_BUSER_WIDTH PARAM_VALUE.C_M_AXI_AUX_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AUX_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_AUX_BUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AUX_USER_VALUE { MODELPARAM_VALUE.C_M_AXI_AUX_USER_VALUE PARAM_VALUE.C_M_AXI_AUX_USER_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AUX_USER_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_AUX_USER_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AUX_PROT_VALUE { MODELPARAM_VALUE.C_M_AXI_AUX_PROT_VALUE PARAM_VALUE.C_M_AXI_AUX_PROT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AUX_PROT_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_AUX_PROT_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_AUX_CACHE_VALUE { MODELPARAM_VALUE.C_M_AXI_AUX_CACHE_VALUE PARAM_VALUE.C_M_AXI_AUX_CACHE_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_AUX_CACHE_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_AUX_CACHE_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV0_ID_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV0_ID_WIDTH PARAM_VALUE.C_M_AXI_QKV0_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV0_ID_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV0_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV0_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV0_DATA_WIDTH PARAM_VALUE.C_M_AXI_QKV0_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV0_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV0_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV0_AWUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV0_AWUSER_WIDTH PARAM_VALUE.C_M_AXI_QKV0_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV0_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV0_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV0_ARUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV0_ARUSER_WIDTH PARAM_VALUE.C_M_AXI_QKV0_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV0_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV0_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV0_WUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV0_WUSER_WIDTH PARAM_VALUE.C_M_AXI_QKV0_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV0_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV0_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV0_RUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV0_RUSER_WIDTH PARAM_VALUE.C_M_AXI_QKV0_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV0_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV0_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV0_BUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV0_BUSER_WIDTH PARAM_VALUE.C_M_AXI_QKV0_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV0_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV0_BUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV0_USER_VALUE { MODELPARAM_VALUE.C_M_AXI_QKV0_USER_VALUE PARAM_VALUE.C_M_AXI_QKV0_USER_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV0_USER_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_QKV0_USER_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV0_PROT_VALUE { MODELPARAM_VALUE.C_M_AXI_QKV0_PROT_VALUE PARAM_VALUE.C_M_AXI_QKV0_PROT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV0_PROT_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_QKV0_PROT_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV0_CACHE_VALUE { MODELPARAM_VALUE.C_M_AXI_QKV0_CACHE_VALUE PARAM_VALUE.C_M_AXI_QKV0_CACHE_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV0_CACHE_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_QKV0_CACHE_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV1_ID_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV1_ID_WIDTH PARAM_VALUE.C_M_AXI_QKV1_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV1_ID_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV1_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV1_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV1_DATA_WIDTH PARAM_VALUE.C_M_AXI_QKV1_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV1_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV1_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV1_AWUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV1_AWUSER_WIDTH PARAM_VALUE.C_M_AXI_QKV1_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV1_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV1_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV1_ARUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV1_ARUSER_WIDTH PARAM_VALUE.C_M_AXI_QKV1_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV1_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV1_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV1_WUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV1_WUSER_WIDTH PARAM_VALUE.C_M_AXI_QKV1_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV1_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV1_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV1_RUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV1_RUSER_WIDTH PARAM_VALUE.C_M_AXI_QKV1_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV1_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV1_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV1_BUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_QKV1_BUSER_WIDTH PARAM_VALUE.C_M_AXI_QKV1_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV1_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_QKV1_BUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV1_USER_VALUE { MODELPARAM_VALUE.C_M_AXI_QKV1_USER_VALUE PARAM_VALUE.C_M_AXI_QKV1_USER_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV1_USER_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_QKV1_USER_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV1_PROT_VALUE { MODELPARAM_VALUE.C_M_AXI_QKV1_PROT_VALUE PARAM_VALUE.C_M_AXI_QKV1_PROT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV1_PROT_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_QKV1_PROT_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_QKV1_CACHE_VALUE { MODELPARAM_VALUE.C_M_AXI_QKV1_CACHE_VALUE PARAM_VALUE.C_M_AXI_QKV1_CACHE_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_QKV1_CACHE_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_QKV1_CACHE_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ATT_OUT_ID_WIDTH { MODELPARAM_VALUE.C_M_AXI_ATT_OUT_ID_WIDTH PARAM_VALUE.C_M_AXI_ATT_OUT_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ATT_OUT_ID_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ATT_OUT_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ATT_OUT_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_ATT_OUT_DATA_WIDTH PARAM_VALUE.C_M_AXI_ATT_OUT_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ATT_OUT_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ATT_OUT_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ATT_OUT_AWUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_ATT_OUT_AWUSER_WIDTH PARAM_VALUE.C_M_AXI_ATT_OUT_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ATT_OUT_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ATT_OUT_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ATT_OUT_ARUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_ATT_OUT_ARUSER_WIDTH PARAM_VALUE.C_M_AXI_ATT_OUT_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ATT_OUT_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ATT_OUT_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ATT_OUT_WUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_ATT_OUT_WUSER_WIDTH PARAM_VALUE.C_M_AXI_ATT_OUT_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ATT_OUT_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ATT_OUT_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ATT_OUT_RUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_ATT_OUT_RUSER_WIDTH PARAM_VALUE.C_M_AXI_ATT_OUT_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ATT_OUT_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ATT_OUT_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ATT_OUT_BUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_ATT_OUT_BUSER_WIDTH PARAM_VALUE.C_M_AXI_ATT_OUT_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ATT_OUT_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ATT_OUT_BUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ATT_OUT_USER_VALUE { MODELPARAM_VALUE.C_M_AXI_ATT_OUT_USER_VALUE PARAM_VALUE.C_M_AXI_ATT_OUT_USER_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ATT_OUT_USER_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_ATT_OUT_USER_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ATT_OUT_PROT_VALUE { MODELPARAM_VALUE.C_M_AXI_ATT_OUT_PROT_VALUE PARAM_VALUE.C_M_AXI_ATT_OUT_PROT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ATT_OUT_PROT_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_ATT_OUT_PROT_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ATT_OUT_CACHE_VALUE { MODELPARAM_VALUE.C_M_AXI_ATT_OUT_CACHE_VALUE PARAM_VALUE.C_M_AXI_ATT_OUT_CACHE_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ATT_OUT_CACHE_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_ATT_OUT_CACHE_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_OBSERVED_ID_WIDTH { MODELPARAM_VALUE.C_M_AXI_OBSERVED_ID_WIDTH PARAM_VALUE.C_M_AXI_OBSERVED_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_OBSERVED_ID_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_OBSERVED_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_OBSERVED_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_OBSERVED_DATA_WIDTH PARAM_VALUE.C_M_AXI_OBSERVED_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_OBSERVED_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_OBSERVED_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_OBSERVED_AWUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_OBSERVED_AWUSER_WIDTH PARAM_VALUE.C_M_AXI_OBSERVED_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_OBSERVED_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_OBSERVED_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_OBSERVED_ARUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_OBSERVED_ARUSER_WIDTH PARAM_VALUE.C_M_AXI_OBSERVED_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_OBSERVED_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_OBSERVED_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_OBSERVED_WUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_OBSERVED_WUSER_WIDTH PARAM_VALUE.C_M_AXI_OBSERVED_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_OBSERVED_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_OBSERVED_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_OBSERVED_RUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_OBSERVED_RUSER_WIDTH PARAM_VALUE.C_M_AXI_OBSERVED_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_OBSERVED_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_OBSERVED_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_OBSERVED_BUSER_WIDTH { MODELPARAM_VALUE.C_M_AXI_OBSERVED_BUSER_WIDTH PARAM_VALUE.C_M_AXI_OBSERVED_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_OBSERVED_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_OBSERVED_BUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_OBSERVED_USER_VALUE { MODELPARAM_VALUE.C_M_AXI_OBSERVED_USER_VALUE PARAM_VALUE.C_M_AXI_OBSERVED_USER_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_OBSERVED_USER_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_OBSERVED_USER_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_OBSERVED_PROT_VALUE { MODELPARAM_VALUE.C_M_AXI_OBSERVED_PROT_VALUE PARAM_VALUE.C_M_AXI_OBSERVED_PROT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_OBSERVED_PROT_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_OBSERVED_PROT_VALUE}
}

proc update_MODELPARAM_VALUE.C_M_AXI_OBSERVED_CACHE_VALUE { MODELPARAM_VALUE.C_M_AXI_OBSERVED_CACHE_VALUE PARAM_VALUE.C_M_AXI_OBSERVED_CACHE_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_OBSERVED_CACHE_VALUE}] ${MODELPARAM_VALUE.C_M_AXI_OBSERVED_CACHE_VALUE}
}

