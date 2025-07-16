### MASTER CHECK SCRIPT
#INIT
vPath="C_CfgPath"
vCfg=$(cat)

#Checks if config file is missing or empty
if [ ! -f "$vPath" ] || [ ! -s "$vPath" ]; then
    vCfg=$(echo $vCfg | jq -r -c '.M_Err = "CFG"')
else
#Otherwise, checks if paths are valid: yt-dlp, ffmpeg, output, sounds. Allows for multiple errors. (TODO: might wanna turn this into a function)
    vCfg=$(cat $vPath)
	if [ ! -f "$(echo $vCfg | jq -r -c '.P_dlp')" ]; then
		vCfg=$(echo $vCfg | jq -r -c '.M_Err = (.M_Err + "DLP")');fi
#	if [ ! -f "$(echo $vCfg | jq -r -c '.P_ff')" ]; then
#		vCfg=$(echo $vCfg | jq -r -c '.M_Err = (.M_Err + "FF")');fi
#	if [ ! -d "$(echo $vCfg | jq -r -c '.P_Out')" ]; then
#		vCfg=$(echo $vCfg | jq -r -c '.M_Err = (.M_Err + "OUT")');fi
#	if [ ! -d "$(echo $vCfg | jq -r -c '.S_Bip')" ]; then
#		vCfg=$(echo $vCfg | jq -r -c '.M_Err = (.M_Err + "SBIP")');fi
#	if [ ! -d "$(echo $vCfg | jq -r -c '.S_Ding')" ]; then
#		vCfg=$(echo $vCfg | jq -r -c '.M_Err = (.M_Err + "SDING")');fi
#	if [ ! -d "$(echo $vCfg | jq -r -c '.S_Error')" ]; then
#		vCfg=$(echo $vCfg | jq -r -c '.M_Err = (.M_Err + "SERROR")');fi
fi
#Prints cfg
echo $vCfg