###MASTER YT-DLP SCRIPT
###INIT
#debugging
echo "DEBUG: Start of Script"
echo "DEBUG: reading S_Bip $1"
echo "DEBUG: reading P_dlp $2"
echo "DEBUG: reading M_URL $3"
echo "DEBUG: reading P_Out $4"
echo "DEBUG: reading M_Mode $5"
echo "DEBUG: reading P_ff $6"
echo "DEBUG: reading M_Quick $7"
#Assign stdin to array
vInp=( "$1" "$2" "$3" "$4" "$5" "$6" "$7" )
echo "DEBUG: reading inputs 1 to 7 in array $vInp"
#Declare variables
vRegexMP4="(.+)\.(webm|avi|wmv)"	#These extensions will be converted to .MP4, as Apple devices cannot read them natively (Quick View).
vRegexCover="(.+)\.(mp3|m4a)"	#Cover-art compatible file formats.
echo "DEBUG: reading regex values MP4:$vRegexMP4 Cover:$vRegexCover"
vCom=( "ytdlpPath" "-o" "This is the output path" "--ffmpeg-location" "This is the path to ffmpeg" "--embed-metadata" "This is where the URL goes")
vCom[1]="${vInp[2]}" #yt-dlp
vCom[3]="${vInp[4]}%(webpage_url_domain)s/%(title)s.%(ext)s" #output
vCom[5]="${vInp[6]}" #ffmpeg
vCom[7]="${vInp[3]}" #url
# Additional arguments will go before item n°7 of vCom array (before URL)
vComSource=("${vCom[@]}")	# This is the default yt-dlp command structure that will get reverted to vCom after executing it.
echo "DEBUG: reading vCom $vCom"
echo "DEBUG: reading vComSource $vComSource"

###FUNCTIONS
#Plays a Bip sound
f_bip() {
	echo "DEBUG: f_bip"
	afplay "${vInp[1]}"&
	sleep .5
	echo "DEBUG: f_bip END"
	return
}
#Runs the yt-dlp command. Prints 
f_dlp() {
	echo "DEBUG: f_dlp"
	echo "DEBUG: about to run yt-dlp as: $vCom"
	vComOut=$($vCom 2>&1)	# Runs yt-dlp (see INIT)
	vComErr=$?	# Gets previous command exit code
	echo "DEBUG: reading vComErr $vComErr"
	echo "DEBUG : reading vComOut $vComOut"
	if (($vComErr >= 1));then
		echo "DEBUG: ImmaculateDLP_MasterError'internal yt-dlp error'"
		exit
	fi
	vCom=("${vComSource[@]}")	# Reset vCom to default
	echo "DEBUG: vCom is supposed to be reset, reading: $vCom"
	f_bip
	echo "DEBUG: f_dlp END"
	return
}
#Checks if extension needs to be converted
f_ext() {
	echo "DEBUG: f_ext"
	vCom=( "${vCom[@]:0:$((${#vCom}-1))}" "--get-filename" "--no-download-archive" "${vCom[@]:$((${#vCom}-1))}" )
	vExt="$(f_dlp)"
	vCom=("${vComSource[@]}")	# Reset vCom to default, mandatory because we ran f_dlp in vExt (variables changes aren't saved)
	echo "DEBUG: reading vExt $vExt"
	if [[ $vExt =~ $vRegexMP4 ]];then vCom=( "${vCom[@]:0:$((${#vCom}-1))}" "--merge-output-format" "mp4" "--remux-video" "mp4" "-S" "vcodec:h264,lang,quality,res,fps,hdr:12,acodec:aac" "${vCom[@]:$((${#vCom}-1))}" ); fi
	if [[ $vExt =~ $vRegexCover ]];then vCom=( "${vCom[@]:0:$((${#vCom}-1))}" "--embed-thumbnail" "${vCom[@]:$((${#vCom}-1))}" );fi
	echo "DEBUG: f_ext END"
	return
}


###MAIN
f_bip
echo "DEBUG: Case statement"
#Run command according to mode
case "${vInp[5]}" in
    1)		#standard
    	echo "DEBUG: case is 1"
		f_ext
		vCom=( "${vCom[@]:0:$((${#vCom}-1))}" "--no-playlist" "${vCom[@]:$((${#vCom}-1))}" )
        ;;
    2)		#standard, mp3
    	echo "DEBUG: case is 2"
		vCom=( "${vCom[@]:0:$((${#vCom}-1))}" "--no-playlist" "-x" "--audio-format" "mp3" "--audio-quality" "0" "--embed-thumbnail" "${vCom[@]:$((${#vCom}-1))}" )
        ;;
    3)		#playlist
    	echo "DEBUG: case is 3"
		f_ext
		vCom[3]="${vInp[4]}%(webpage_url_domain)s/%(playlist)s/%(playlist_index)s. %(title)s.%(ext)s"
		vCom=( "${vCom[@]:0:$((${#vCom}-1))}" "--yes-playlist" "${vCom[@]:$((${#vCom}-1))}" )
        ;;
    4)		#playlist, mp3
    	echo "DEBUG: case is 4"
    	vCom[3]="${vInp[4]}%(webpage_url_domain)s/%(playlist)s/%(playlist_index)s. %(title)s.%(ext)s"
		vCom=( "${vCom[@]:0:$((${#vCom}-1))}" "--yes-playlist" "-x" "--audio-format" "mp3" "--audio-quality" "0" "--embed-thumbnail" "${vCom[@]:$((${#vCom}-1))}" )
        ;;
    *)
        echo "DEBUG: ImmaculateDLP_MasterError'invalid M_Mode'"
        exit
        ;;
esac
f_dlp
if [ "${vInp[7]}" = 0 ];then open ${vInp[4]};fi
f_bip
echo "DEBUG: End of Script"