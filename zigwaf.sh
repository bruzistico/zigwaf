#!/usr/bin/env bash
#-Metadata----------------------------------------------------#
#  Filename: zigwaf (v1.0)      (update: 2023-03-23)   				#
#-Info--------------------------------------------------------#
#  Identify WAF bypass via IP         						  					#
#-Author(s)---------------------------------------------------#
#  Bruzistico ~ @bruzistico                                   #
#-Operating System--------------------------------------------#
#  Designed for & tested on: Linux	 	                   	    #
#  Reported working : Ubuntu 20                               #
#	   	  : Parrot	 				      					  									#
#       : Kali Linux		 								      								#
#		    : WSL Windows (10.0.17134 N/A Build 17134		  				#
#		    : MacOS (Mojave)			      				  								#
#-Licence-----------------------------------------------------#
#  MIT License ~ http://opensource.org/licenses/MIT           #
#-------------------------------------------------------------#

#clear
### Variable Name and Version ------------------------------------------------------------------------

APPNAME="zigwaf.sh"
VERSION="1.0#dev"

#### Colors Outputs -----------------------------------------------------------------------------------

RESET="\033[0m"			# Normal Colour
RED="\033[0;31m" 		# Error / Issues
GREEN="\033[0;32m"		# Successful       
BOLD="\033[01;01m"    	# Highlight
YELLOW="\033[0;33m"		# Warning
PADDING="  "
DPADDING="\t\t"
RPADDING="\t"
LGRAY="\033[0;37m"		# Light Gray
LRED="\033[1;31m"		# Light Red
LGREEN="\033[1;32m"		# Light GREEN
LBLUE="\033[1;34m"		# Light Blue
LPURPLE="\033[1;35m"	# Light Purple
LCYAN="\033[1;36m"		# Light Cyan
SORANGE="\033[0;33m"	# Standar Orange
IORANGE="\033[3;33m" 	# Italic Orange
SBLUE="\033[0;34m"		# Standar Blue
SPURPLE="\033[0;35m"	# Standar Purple      
SCYAN="\033[0;36m"		# Standar Cyan
DGRAY="\033[1;30m"		# Dark Gray

#### Banner ---------------------------------------------------------------------------------------------
goBanner(){

	echo -e "${GREEN}     ,,                ,,${RESET}          ______                  "
	echo -e "${GREEN}   (((((              )))))${RESET}       |__  (_) __ _            "
	echo -e "${GREEN}  ((((((              ))))))${RESET}        / /| |/ _\` |          "  
	echo -e "${GREEN}  ((((((              ))))))${RESET}       / /_| | (_| |           "
	echo -e "${GREEN}   (((((,r@@@@@@@@@@e,)))))${RESET}       /____|_|\__, |           "
	echo -e "${GREEN}    (((@@@@@@@@@@@@@@@@)))${RESET}                |___/            "
	echo -e "${GREEN}     \@@/,:::,\/,:::,\@@${RESET}       __        ___    _____      "
	echo -e "${GREEN}    /@@@|:::::||:::::|@@@\ ${RESET}    \ \      / / \  |  ___|     "
	echo -e "${GREEN}   / @@@\':::'/\':::'/@@@ \ ${RESET}    \ \ /\ / / _ \ | |_        "
	echo -e "${GREEN}  /  /@@@@@@@//\\\\\@@@@@@@\ \ ${RESET}     \ V  V / ___ \|  _|    "
	echo -e "${GREEN} (  /  '@@@@@====@@@@@'  \  )${RESET}     \_/\_/_/   \_\_|         "
	echo -e "${GREEN}  \(     /          \     )/${RESET}                               "
	echo -e "${GREEN}    \   (            )   /${RESET}    Identify WAF bypass via IP "
	echo -e "${GREEN}         \          /${RESET}          V{1.0#dev} by ${GREEN}@bruzistico${RESET} "
	echo -e "                     ${SBLUE}https://github.com/bruzistico/zigwaf${RESET}\n"

}

#### Help --------------------------------------------------------------------------------------------------
goHelp() {
  echo -e ""	
  echo -e " ${BOLD}Basic usage${RESET}:"
  echo -e "${PADDING}${SORANGE}$0${RESET} ${GREEN}-d${RESET} example.com ${GREEN}-i${RESET} 192.168.0.10"
  echo -e "${PADDING}${SORANGE}$0${RESET} ${GREEN}-d${RESET} example.com ${GREEN}-iL${RESET} listips.txt"
  echo -e "${PADDING}${SORANGE}$0${RESET} ${GREEN}-dL${RESET} domainlist.txt ${GREEN}-i${RESET} 192.168.0.10"
  echo -e "${PADDING}${SORANGE}$0${RESET} ${GREEN}-dL${RESET} domainlist.txt ${GREEN}-iL${RESET} listip.txt ${GREEN}-v${RESET}"
  echo -e "${PADDING}${SORANGE}$0${RESET} ${GREEN}-dL${RESET} domainlist.txt ${GREEN}-iL${RESET} listip.txt ${GREEN}-v${RESET} ${GREEN}-o ${RESET}result.txt"
  echo -e ""
  echo -e " ${RED}[INFO]${RESET} It is mandatory to inform domain targets [${GREEN}-d${RESET} or ${GREEN}-dL${RESET}] ${BOLD}${LPURPLE}and${RESET} IP targets [${GREEN}-i${RESET} or ${GREEN}-iL${RESET}]"
  echo -e ""
  echo -e " ${BOLD}Options:${RESET}"
  echo -e "${PADDING}${BOLD}${GREEN}-d, ${RESET} --domain${DPADDING} Analyzing one target subdomain/domain (e.g example.com, https://example.com)"
  echo -e "${PADDING}${BOLD}${GREEN}-dL,${RESET} --domain-list\t Analyzing multiple targets in a text file "
  echo -e "${PADDING}${BOLD}${GREEN}-i, ${RESET} --ip${DPADDING} Parse DNS via real IP, bypass WAF (e.g 192.168.0.10)"
  echo -e "${PADDING}${BOLD}${GREEN}-iL,${RESET} --ip-list${RPADDING} Parse DNS via real IP, bypass WAF in a text file"
  echo -e "${PADDING}${BOLD}${GREEN}-o, ${RESET} --output${DPADDING} Output (eg. output.txt)"
  echo -e "${PADDING}${BOLD}${GREEN}-v, ${RESET} --verbose${RPADDING} Verbose"
  echo -e "${PADDING}${BOLD}${GREEN}-h, ${RESET} --help${DPADDING} Help [Usage]"
}

[[ "${#}" == 0 ]] && {
	goBanner
	goHelp && exit 1
}

##=======================================================================================================================
##
## FUNCTIONS
##
##=======================================================================================================================

checkArguments(){
    options+=(-d --domain -dL -dL -i --ip -iL --ip-list -o --output)
    if [[ "${options[@]}" =~ "$2" ]]; then
            echo -e ""
            echo -e " The argument of \"${GREEN}$1${RESET}\" it can not be ${RED}\"$2\"${RESET}, please, ${SORANGE}specify a valid one${RESET}."
            goHelp
    fi
}

msg_Done(){

	msg="$(
		echo ""
		echo -e " Done!"
		)"
	echo "${msg}"

}

msg_subHeader(){
	
	echo ""
	echo -e "${BOLD} Analyzing domain IP - WAF:"
	echo -e "${DPADDING}"
	echo -e "${BOLD} [    STATUS    ] DOMAIN >> IP RESOLVE"

}

progress_bar(){
  
  if [[ "${dlil}" == true ]];then
  	f1=$(grep -c "" ${file1})
  	f2=$(grep -c "" ${file2})
  	rows=$((($f1) * ($f2)))
  else
  	rows=$(grep -c "" ${file})
  fi
  clear_line="\\033[K"
  bar_size="#######################################"
  max_bar=${#bar_size}
  let counter++
  percent=$((($counter) * 100 / $rows))
  percBar=$((${percent} * ${max_bar} / 100))

	if [[ ${bypass} == true ]] && [[ "${KEY_VERBOSE}" == "" ]]; then
	 	echo -ne "${msgbypass}"
	fi

	if [[ "${KEY_VERBOSE}" == true ]] || [[ "${KEY_DOMAIN}" == true && -n "${DOMAIN}" && "${KEY_LISTIP}" == "" ]]; then
		echo -ne "\\r${msg}${clear_line}\\n"
	fi
	
	echo -ne "\\r Progress: [${bar_size:0:percBar}] $percent %$clear_line"

}

Original(){

		original="$(timeout --signal=9 2 curl -Lsk "{$DOMAIN}")"
	
		title_original="$(echo "{$original}" | grep "<title>" | awk -F "<title>" '{print $2}' | awk -F "</title>" '{print $1}' | awk -F "-" '{print $1}' | shasum | awk -F "-" '{print $1}') "
	
		li_original="$(echo "{$original}" | grep "<li><a href=" | awk -F "://" '{print $2}' | awk -F "\"" '{print $1}' | shasum | awk -F "-" '{print $1}')"
	
		meta_original="$(echo "{$original}" | grep "<meta" | awk -F "<meta" '{print $2}' | awk -F ">\"" '{print $1}' | shasum | awk -F "-" '{print $1}')"
	
		links_original="$(echo "{$original}" | grep "<link" | awk -F "<link" '{print $2}' | awk -F ">\"" '{print $1}' | shasum | awk -F "-" '{print $1}')"
	
		comment_original="$(echo "{$original}" | grep "<!--" | awk -F "<!--" '{print $2}' | awk -F "-->" '{print $1}' | shasum | awk -F "-" '{print $1}')"
	
		favicon_original="$(timeout --signal=9 2 curl -sLk "{$DOMAIN}/favicon.ico" | shasum | awk -F "-" '{print $1}')"

}

Bypass(){
	
		bypass="$(timeout --signal=9 2 curl -Lsk "${DOMAIN}" --resolve "${DOMAIN}":80:"${IP}" --resolve "${DOMAIN}":443:"${IP}")"
	
		title_bypass="$(echo "{$bypass}" | grep "<title>" | awk -F "<title>" '{print $2}' | awk -F "</title>" '{print $1}' | awk -F "-" '{print $1}' | shasum | awk -F "-" '{print $1}') "

		li_bypass="$(echo "{$bypass}" | grep "<li><a href=" | awk -F "://" '{print $2}' | awk -F "\"" '{print $1}' | shasum | awk -F "-" '{print $1}')"

		meta_bypass="$(echo "{$bypass}" | grep "<meta" | awk -F "<meta" '{print $2}' | awk -F ">\"" '{print $1}' | shasum | awk -F "-" '{print $1}')"
	
		links_bypass="$(echo "{$bypass}" | grep "<link" | awk -F "<link" '{print $2}' | awk -F ">\"" '{print $1}' | shasum | awk -F "-" '{print $1}')"
	
		comment_bypass="$(echo "{$bypass}" | grep "<!--" | awk -F "<!--" '{print $2}' | awk -F "-->" '{print $1}' | shasum | awk -F "-" '{print $1}')"
	
		favicon_bypass="$(timeout --signal=9 2 curl -sLk "{$DOMAIN}/favicon.ico" --resolve "${DOMAIN}":80:"${IP}" --resolve "${domain}":443:"${IP}" | shasum | awk -F "-" '{print $1}')"

}

Compare(){

		if [[ "${title_original}" == "${title_bypass}" ]] && \
			 [[ "${li_original}" == "${li_bypass}" ]] && \
			 [[ "${meta_original}" == "${meta_bypass}" ]] && \
			 [[ "${links_original}" == "${links_bypass}" ]] && \
			 [[ "${comment_original}" == "${comment_bypass}" ]] && \
			 [[ "${favicon_original}" == "${favicon_bypass}" ]]; then		
				
				msgbypass="\\r [$GREEN Bypass OK :) $RESET] $SBLUE"${DOMAIN}"$RESET $YELLOW>> $RESET"${IP}${clear_line}\\n""
				
				msg=" [$GREEN Bypass OK :) $RESET] $SBLUE"${DOMAIN}"$RESET $YELLOW>> $RESET"${IP}""

				bypass=true

				if [[ ${unique} == true ]]; then
					echo -e "${msg}"
				fi

				if [[ "${KEY_OUTPUT}" == true ]]; then
						echo "${DOMAIN} | ${IP}" >> "${OUTPUT}"
				fi 

		else
			
				if [[ "${KEY_VERBOSE}" == true ]] || [[ "${KEY_DOMAIN}" == true && -n "${DOMAIN}" && "${KEY_LISTIP}" == "" ]]; then
	
					msg=" [$RED NO Bypass :( $RESET] $SBLUE"${DOMAIN}"$RESET $YELLOW>> $RESET"${IP}""

					bypass=false

					if [[ ${unique} == true ]]; then
						echo -e "${msg}"
					fi

				fi
		fi


}

##=======================================================================================================================
##
## COMMAND LINE SWITCHES
##
##=======================================================================================================================

while [[ "${#}" -gt 0 ]]; do
 	args="${1}"
 	case "$(echo ${args})" in
 		# Subdomain/Domain unique
 		"-d" | "--domain")
		  checkArguments $1 $2
 		  DOMAIN="${2}"
 		  KEY_DOMAIN=true
 		  shift
 		  shift
 		  ;;
 		# List Subdomain/Domain [file]
 		"-dL" | "--domain-list")
		  checkArguments $1 $2
		  if [[ -f ${2} ]] && [[ -r ${2} ]]; then
		    LISTDOMAIN="${2}"
		    KEY_LISTDOMAIN=true
		  else
		  	echo ""
		  	echo -e " ${SORANGE}[i]${RESET} Invalid file: The file ${RED}"${2}"${RESET}"
				echo -e "${PADDING} ${RED}"${2}"${RESET} [not found - invalid - read permissions]"
				echo -e "${PADDING} Please insert a valid file for the option ${GREEN}${1}${GREEN}"
		  fi
 		  shift
 		  shift
 		  ;;
 		# IP unique
 		"-i" | "--ip")
		  checkArguments $1 $2
 		  IP="${2}"
 		  KEY_IP=true
 		  shift
 		  shift
 		  ;;
 		# List IP [file] 
 		"-iL" | "--ip-list")
		  checkArguments $1 $2
		  if [[ -f ${2} ]] && [[ -r ${2} ]]; then
		    LISTIP="${2}"
		    KEY_LISTIP=true
		  else
		  	echo -e " ${SORANGE}[i]${RESET} Invalid file: The file ${RED}"${2}"${RESET}"
				echo -e "${PADDING} ${RED}"${2}"${RESET} [not found - invalid - read permissions]"
				echo -e "${PADDING} Please insert a valid file for the option ${GREEN}${1}${GREEN}"
		  fi
 		  shift
 		  shift
 		  ;;
 		# Output 
 		"-o" | "--output")
		  checkArguments $1 $2
 		  OUTPUT="${2}"
 		  KEY_OUTPUT=true
 		  shift
 		  shift
 		  ;;  
 		# Verbose
 		"-v" | "--verbose")
 		  KEY_VERBOSE=true
 		  shift
 		  ;;
 		# Help
 		"-h" | "--help" )
			goBanner;
			goHelp;
			shift
			shift
		;;
 		"-"*)
 		  echo -e " ${SORANGE}[i]${RESET} Invalid option: ${RED}${1}${RESET}" && goHelp && shift && exit 1
 		  ;;
 		*)
 		  echo -e " ${SORANGE}[i]${RESET} Invalid: Unknown option ${RED}${1}${RESET}" && goHelp && shift && exit
 		  exit
 		  ;;
 	esac	
done

##=======================================================================================================================
##
## IFS ARGUMENTS - 
##
##========================================================================================================================
tput civis
## IF -d [Subdomain/Domain unique] ---------------------------------------------------------------------------------------
##
if [[ "${KEY_DOMAIN}" == true ]] && [[ -n "${DOMAIN}" ]]; then
	###############################################################
	## Case -d -i [IP unique]---------------------------------------
	################################################################
	if [[ "${KEY_IP}" == true ]] && [[ -n "${IP}" ]]; then
		unique=true
		goBanner
		msg_subHeader
		Original
		Bypass
		Compare
		msg_Done
		exit 0
	fi
	#################################################################

	##################################################################
	## Case -d -iL [List IP [file]]------------------------------------
	##################################################################

	if [[ "${KEY_LISTIP}" == true ]] && [[ -n "${LISTIP}" ]]; then
		goBanner
		msg_subHeader
		Original
		for line in $(cat ${LISTIP}); do
	 			IP="${line}"
	 			file=${LISTIP}
	 			Bypass
	 			Compare
	 			progress_bar
	 		done
	 	msg_Done
		exit 0
	fi
	#####################################################################
fi

##------------------------------------------------------------------------------------------------------------------------
##
##IF -dL [List Subdomain/Domain [file]]----------------------------------------------------------------------------
##
if [[ "${KEY_LISTDOMAIN}" == true ]] && [[ -n "${LISTDOMAIN}" ]]; then
	##########################################################################
	## Case -dL -i [IP unique]--------------------------------------------------
	##########################################################################
	if [[ "${KEY_IP}" == true ]] && [[ -n "${IP}" ]]; then
		goBanner
		msg_subHeader
			for line in $(cat ${LISTDOMAIN}); do	
				DOMAIN="$(echo "$line" | sed 's/\r//g')"
				file="${LISTDOMAIN}"
				Original
				Bypass
				Compare
				progress_bar
			done
		msg_Done
		exit 0
	fi
	############################################################################

	#############################################################################
	## Case -dL -iL [List IP [file]]-----------------------------------------------
	##########################################################################
	if [[ "${KEY_LISTIP}" == true ]] && [[ -n "${LISTIP}" ]]; then
		dlil=true
		goBanner
		msg_subHeader
			for line in $(cat ${LISTDOMAIN}); do	
				DOMAIN="$(echo "$line" | sed 's/\r//g')"
				Original
				file1="${LISTDOMAIN}"
				for ip in $(cat ${LISTIP}); do
					IP="${ip}"
					file2="${LISTIP}"
					Bypass
					Compare
					progress_bar
				done
			done
		msg_Done
		exit 0
	fi
	############################################################################
fi
##############
tput cnorm
##----------------------------------------------------------------------------------------------------------------------
##
## END
##====================================================================================================================