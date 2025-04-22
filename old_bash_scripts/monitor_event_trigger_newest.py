import argparse, requests, json, os, re
from datetime import datetime, timedelta

valid_Events = ["pipeStarted", "pipeUpdate", "pipeCompleted", "pipeError", "processFallback", \
	"varbankTransferStart", "varbankTransferError", "varbankTransferCompleted",\
	"varbankUploadStart", "varbankUploadError", "varbankUploadCompleted"]

update_Events = ["pipeCompleted", "pipeUpdate", "pipeError"]
parse = argparse.ArgumentParser(description="""

* Trigger Script for Status Monitoring *

  ~> depending on `-event` input different arguments are required

--------------
""", formatter_class=argparse.RawTextHelpFormatter)


# always required
always_req = parse.add_argument_group('--------------\nALWAYS required arguments')
always_req.add_argument('-event', dest='event', required=True, help="Event of to be posted (%s)" % ", ".join(valid_Events)) 
always_req.add_argument('-fall', dest='fallb', required=True, help="Fallback directory")

pipe_req = parse.add_argument_group('--------------\nRequired for any event besides processFallback  - required\n(sufficient for any complete event)')
pipe_req.add_argument('-uuid', dest='uuid', help="uuID for Pipeline run Submission")
pipe_req.add_argument('-serv', dest='server', help="Server address to receive json file")

# Pipe Start Args
submit_req = parse.add_argument_group('--------------\npipeStarted - required')
submit_req.add_argument('-host', dest='host', help="Server hosting run (cheops0/raptor1)")


submit_opt = parse.add_argument_group("pipeStarted - optional")
submit_opt.add_argument('-rid', dest='runid',help='Nextflow session ID')
submit_opt.add_argument('-rname', dest='runname', help="Nextflow Runname")
submit_opt.add_argument('-framew', dest='framew', help="Framework of job (Nextflow/Snakemake/Inhouse)")
submit_opt.add_argument('-ptype', dest='ptype', help="Type of Pipeline (WGS/WES/demult/amplicon/RNA/cellranger/delivery)")
submit_opt.add_argument('-psubt', dest='psubtype', help="Subtype of pipeline")
submit_opt.add_argument('-pversion', dest='pversion', help="Version ID of Pipeline")
submit_opt.add_argument('-script', dest='script', help="Path to script being run")
submit_opt.add_argument('-aid', dest='aid', help="Analysis ID of run")
submit_opt.add_argument('-sid', dest='sid', help="Sample ID of run")
submit_opt.add_argument('-prid', dest='prid', help="Project ID of run")
submit_opt.add_argument('-pshort', dest='pshort', help="Shortcut for project")

#logfiles, can be multiple
submit_opt.add_argument('-ltype', dest='logtype', action='append', help="Type of logfile(s) (logFile, traceFile, reportFile, timelineFile)")
submit_opt.add_argument('-lpath', dest='logpath', action='append', help="Path to logfile(s)")

submit_opt2 = parse.add_argument_group("pipeStarted - if '-psubt trio_CHILD/trio_MOTHER/trio_FATHER' - optional")
submit_opt2.add_argument('-msid', dest='motherSid', help="Mother SID")
submit_opt2.add_argument('-fsid', dest='fatherSid', help="Father SID")

submit_opt3 = parse.add_argument_group("pipeStarted - if '-ptype DMP' - optional")
submit_opt3.add_argument('-rfolder', dest='runFolder', help="Runfolder")
submit_opt3.add_argument('-plateid', dest='plateId', help="PlateID")

# Pipe Error Args
error_req = parse.add_argument_group("--------------\npipeError - required")
error_req.add_argument('-emsg', dest='errmessage', help="Message of error")

error_opt = parse.add_argument_group("pipeError - optional")
error_opt.add_argument('-exs', dest='exstat', help="Exit status of error")
error_opt.add_argument('-erep', dest='errreport', help="Report of error")
error_opt.add_argument('-elog', dest='errlog', help="Path to Error Logfile")

dev_args = parse.add_argument_group("--------------\nDevelopment arguments (optional)")
dev_args.add_argument('-debug', dest='debug', help="Dont send Json file, just print it (if '-debug true')")

try:
	args = parse.parse_args()

except:
	exit('Parsing of arguments failed!')

##################
# Helper Methods #
##################
def representsInt(s):
	'''
	Helper function to check whether input String resembles Integer
	
	input: String to check
	output: Boolean indication if inout String resembles Integer
	'''
	try: 
		int(s)
		return True
	except:
		return False

def generateUtcTime():
	return datetime.utcnow().isoformat()[:-3]+'Z'

def getXauthToken(hostname):

	# parse monitoring login from environment variable
	try:
		username, password = os.popen("echo $CCG_MONITORING").read().split(":")  # parse from variable
		password = password[:-1]  # remove newline 
	except:
		exit("Monotoring account data not parsable from CCG_MONITORING variable (%s). Should be in format: username:password" % os.popen("echo $CCG_MONITORING").read()[:-1])

	#build json to get x-auth token
	headers = {
    'Content-Type': 'application/json',
	}

	data = '{"loginName": "%s", "password" : "%s"}' % (username, password)

	response = requests.post('%s/api/auth' % hostname, headers=headers, data=data)

	if response.status_code == 200:  # success
		token = json.loads(response._content.decode("utf-8"))["x-auth-token"]  # parse x-auth token from data
		
		return token
		
	elif response.status_code == 400:  # not successful
		if response._content:  # avoid json parsing errors
			exit("X-Auth token request unsuccessful, received following data: '%s'" % response._content.decode("utf-8"))
		else:
			exit("X-Auth token request unsuccessful, received no data.")
	
	else:  # unknown response code
		print("Unknown response code from x-auth token request: %s" % response.status_code)
		if response._content:  # avoid json parsing errors
			print("Following data was received: %s" % response._content)
		exit()

def checkIfhostValid(host):
	
	# host requires http or https for sending request
	if host.startswith("http://") or host.startswith("https://"):
		return host
	else:
		exit("Ivalid server address, -serv requires http:// or https:// prefix")

###########################
# check Arguments Methods #
###########################
def checkPipeStartOrUpdateArgs(args_dict):
	'''
	check input arguments for submit pipe event for type correctness
	input: dict w/ parse args
	output: dict w/ type checked args
	'''

	output_dict = {}

	uuidv4_regex ="^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-4[0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$"
	valid_frameworks = ['Nextflow', 'Snakemake', 'Inhouse']
	valid_pTypes = ['WGS', 'WES', 'amplicon', 'RNA', 'cellranger', 'demult', 'delivery']
	valid_pSubtypes = ['single', 'trio_CHILD','trio_MOTHER','trio_FATHER', 'pair_NORMAL', 'pair_AFFECTED']
	valid_hosts = ['cheops0', 'raptor1']
	valid_logtypes = ['logFile', 'traceFile', 'reportFile', 'timelineFile']
	lims_fields = ["prid", "sid", "aid", "pshort"]
	
	# before typecheck: check if equal numbers of logPaths and logFiles are supplied
	# if not args_dict["logtype"] or not args_dict["logpath"]:
	# 	exit("Please supply minimun 1 logfile and its corresponding type")

	# when started logs optional: only check when present
	if args_dict["logtype"] and args_dict["logpath"] and len(args_dict["logtype"]) != len(args_dict["logpath"]):
		exit("Please supply equal amount of logpaths and logtypes")

	# iterate like this to be compatible w/ python2 & python3
	for key in args_dict:
		#print(key, args_dict[key])

		# event is already checked, dirctly transfer to output dict
		if key == "event":
			output_dict[key] = args_dict[key]
		
		# time is generated from script - no need to check
		if key == "utcTime":
			output_dict[key] = args_dict[key] 

		if key == "uuid":
			output_dict[key] = args_dict[key] if args_dict[key] and re.search(uuidv4_regex, args_dict[key]) else exit("uuID not valid, please supply -uuid in uuid v4 format")

		if key == "host" and parsed_event == "pipeStarted":  # Host has to be one of valid hosts (cheops0 or raptor1)
			output_dict[key] = args_dict[key] if args_dict[key] in valid_hosts else exit("Pipeline host invalid, -host has to be one of (%s) for pipeStarted" % ", ".join(valid_hosts))
		elif key == "host" and parsed_event == "pipeUpdate" and args_dict[key]:
			print(" '-host' not required for pipeUpdate, will be ignored")
		
		# optional arguments
		if key == "runid" and args_dict[key]:
			if args_dict["framew"] == "Nextflow":  # if run is nextflow, runid has to be in uuidv4 format
				output_dict[key]=args_dict[key] if re.search(uuidv4_regex, args_dict[key]) else exit("runID not valid, if \"-framew Nextflow\" please supply -rid in uuid v4 format")
			else:  # if its not Nextflow, take any runid
				output_dict[key]=args_dict[key]
		
		if key == "runname" and args_dict[key]:
			if args_dict["framew"] == "Nextflow":  # if framework = Nextflow: runname has to be min 3 chars long
				output_dict[key]=args_dict[key] if args_dict[key] and len(args_dict[key]) >= 3 else exit("RunName invalid, if \"-framew Nextflow\" -runname requires a min length of 3")
			else:
				output_dict[key]=args_dict[key]
		
		if key == "framew" and args_dict[key]:  # check if supplied framework is valid
			output_dict[key] = args_dict[key] if args_dict[key] in valid_frameworks else exit("Pipeline framework invalid, -framew has to one of (%s)" % ", ".join(valid_frameworks))
		
		if key == "ptype" and args_dict[key]:  # check if pipeline type is one of valid ones
			output_dict[key] = args_dict[key] if args_dict[key] in valid_pTypes else exit("Please enter valid Pipeline type -ptype (%s)" % ", ".join(valid_pTypes))
		
		if key == "psubtype" and args_dict[key]:  # if pipeType is WES, WGS check if pSubtype is valid, else take any subtype
			# if WES or WGS: only certain subtypes are valid
			if args_dict["ptype"] in ["WES", "WGS"]:
				
				if args_dict[key] == "single":
					output_dict[key] = args_dict[key]
					if args_dict["motherSid"]: print("Found unneccesary argument, if '-psubt single' -msid is not required\n")
					if args_dict["fatherSid"]: print("Found unneccesary argument, if '-psubt single' -fsid is not required\n")
				
				elif args_dict[key].startswith("trio") and args_dict[key] in valid_pSubtypes:
					output_dict[key] = "trio"
				
				elif args_dict[key].startswith("pair") and args_dict[key] in valid_pSubtypes:
					output_dict[key] = "pair"
				else:
					exit("Pipeline subtype invalid, if '-ptype (WES, WGS)' please supply valid -psubt (%s)." % ", ".join(valid_pSubtypes))
				
				#output_dict[key]=args_dict[key] if args_dict[key] in valid_pSubtypes else exit("Pipeline subtype invalid, if \"-ptype (WES, WGS)\" please supply valid -psubt (%s)." % ", ".join(valid_pSubtypes))
				
				# trio child: get any of fsid or msid 
				if args_dict[key] == "trio_CHILD":
					if args_dict["motherSid"]: output_dict["motherSid"] = args_dict["motherSid"] if representsInt(args_dict["motherSid"]) else exit("Mother SID invalid, if '-psubt trio_CHILD' -msid has to resemble an Integer")
					if args_dict["fatherSid"]: output_dict["fatherSid"] = args_dict["fatherSid"] if representsInt(args_dict["fatherSid"]) else exit("Father SID invalid, if '-psubt trio_CHILD' -fsid has to resemble an Integer")

			else:  # if no WEG or WGS: parse any subtype given
				output_dict[key] = args_dict[key]
			
			# if single or trio (indep. of ptype) project shortcut is required
			#if args_dict[key] == "trio" or args_dict[key] == "single":
				#output_dict["pshort"] = args_dict["pshort"] if args_dict["pshort"] and len(args_dict["pshort"]) >= 3 else exit("Project shortcut invalid, if -psubt (single/trio) -pshort  requires min length of 3")
			
		if key == "pshort" and args_dict[key]:
			output_dict[key] = args_dict[key] if len(args_dict[key]) >= 3 else exit("Project shortcut invalid, -pshort  requires min length of 3")	
		
		if key == "pversion" and args_dict[key]:  # Pipeline version id reviures min length of 2
			
			output_dict[key] = args_dict[key] if len(args_dict[key]) > 2 else exit("Pipeline version invalid, -pversion requires min length of 2")

		if key == "script" and args_dict[key]:  # script requires min length of 3
			output_dict[key]=args_dict[key] if args_dict[key] and len(args_dict[key]) >= 3 else exit("Pipeline script path invalid, -script requires min length of 3")

		if key == "prid" and args_dict[key]:  # check Prid to resemble an integer
			output_dict[key]=args_dict[key] if representsInt(args_dict[key]) else exit("PRID invalid, -prid has to resemble an Integer")
		
		if key == "sid" and args_dict[key]:  # check Sid to resemble an integer
			output_dict[key]=args_dict[key] if representsInt(args_dict[key]) else exit("SID invalid, -sid has to resemble an Integer")
		
		if key == "aid" and args_dict[key]:  # check Aid to resemble an integer
			output_dict[key]=args_dict[key] if representsInt(args_dict[key]) else exit("AID invalid, -aid has to resemble an Integer")
		
		if key == "logtype" and args_dict[key]:  # check if all logtypes are valid ones
			output_dict[key] = args_dict[key] if all([x in valid_logtypes for x in args_dict[key]]) else exit("Logtype invalid, all -ltype args for pipeStarted have to one of (%s)" % ", ".join(valid_logtypes))
		
		if key == "logpath" and args_dict[key]:  # check if all logpaths have min length of 
				output_dict[key] = args_dict[key] if all([len(x) >= 3 for x in args_dict[key]]) else exit("Logpath invalid, all -logpath args require min length of 3")
	
		if key == "runFolder" and args_dict[key]:
			if  args_dict["ptype"] == "demult":  # only tranfser -rfolder if dmp ptype
				output_dict[key] = args_dict[key] if len(args_dict[key]) >= 10 else exit("-rfolder required a min length of 10")
			else:
				print("unnecessary -rfolder argument supplied!")
		
		if key == "plateId" and args_dict[key]:
			if args_dict["ptype"] == "demult":
				output_dict[key] = args_dict[key] if len(args_dict[key]) >= 1 and int(args_dict[key]) > 0 else exit("-plateid required a min length of 1 and has to resemble an integer > 0")
			else:
				print("unnecessary -plateid argument supplied!")
				
	# Check completeness of lims arguments
	lims_present = [x for x in output_dict.keys() if x in lims_fields]  # get present lims args to get missing ones
	lims_missing = [x for x in lims_fields if x not in lims_present]  # get missing lims entries
	
	# if not all but only some lims info: info print
	if len(lims_missing) > 0 and len(lims_missing) < len(lims_fields):
		print("Found insufficient LIMS arguments, skipping %s for submission, missing: %s" % (", ".join(["-" + x for x in lims_present]), ", ".join(["-" + x for x in lims_missing])))
		#print("-> Following arguments are missing for LIMS info to be included: %s" % )
		print
	
	# if demult: both rfolder and plateid have to be present *REMOVED*
	# if args_dict["ptype"] == "demult":
		# both present -> fine
		# some present -> exit w/ info print
		# non present -> fine
		# if any(not x in output_dict.keys() for x in ["plateId", "runFolder"]):
			# exit("If '-pType demult': please supply either both -rfolder and -plateid or none, not only one of them.")


	# after checking args, return output dictionary
	return output_dict

def checkOtherStartArgs(args_dict):
	# regex patterns for UTC time & uuId
	uuidv4_regex ="^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-4[0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$"
	
	# dictionary for colecting type checked args
	output_dict = {}

	# iterate args
	for key in args_dict:
		# event has to adjusted for json transfer
		if key == "event":
			output_dict[key] = "otherStarted"
		
		# time is generated from script - no need to check
		if key == "utcTime":
			output_dict[key]=args_dict[key] 
		
		if key == "uuid":  # check uuid is in uuid v4
			output_dict[key] = args_dict[key] if args_dict[key] and re.search(uuidv4_regex, args_dict[key]) else exit("uuID invalid, please supply -uuid in uuid v4 format")
		
		if key == "host":
			output_dict["otherHost"] = args_dict[key] if args_dict[key] and len(args_dict[key]) >= 3 else exit("Pipeline host invalid, -host requires min. length of 3")
		
		if key == "logpath":
			output_dict["otherLogFile"] = args_dict[key][0] if args_dict[key] and args_dict[key][0] and len(args_dict[key][0]) >= 3 and os.path.isfile(args_dict[key][0]) else exit("logFile path, -lpath requires min. length of 3 AND has to be a valid file.")

	# set Other type, so far: 2 choices, varbank transfer or db upload
	output_dict["otherType"] = "varbankTransfer"\
		if parsed_event.startswith("varbankTransfer")\
			else "varbankUploadDb"

	return output_dict

def checkErrorArgs(args_dict):
	'''
	check input arguments for error pipe event for type correctness
	input: dict w/ parse args
	output: dict w/ type checked args
	'''

	# regex patterns for UTC time & uuId
	uuidv4_regex ="^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-4[0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$"
	
	# dictionary for colecting type checked args
	output_dict = {}

	# iterate args
	for key in args_dict:

		# event is already checked, directly transfer to output dict
		if key == "event":
			output_dict[key] = args_dict[key]
		
		# time is generated from script - no need to check
		if key == "utcTime":
			output_dict[key]=args_dict[key] 

		if key == "uuid":  # check uuid is in uuid v4
			output_dict[key] = args_dict[key] if args_dict[key] and re.search(uuidv4_regex, args_dict[key]) else exit("uuID invalid, please supply -uuid in uuid v4 format")
			
		if key == "errmessage":  # required, has to have min length of 3
			output_dict["pipeErrorMessage"] = args_dict[key] if args_dict[key] and len(args_dict[key]) >= 3 else exit("Error Message invalid, -emsg requires minimum length of 3")
		
		# optional args
		if key == "exstat" and args_dict[key]:  #  has to resemble Integer
			  output_dict["pipeExitStatus"] = args_dict[key] if representsInt(args_dict[key]) else exit("Exit Status invalid, -exs has to resemble an Integer")

		if key == "errreport" and args_dict[key]:  # has to have min length of 3
			  output_dict["pipeErrorReport"] = args_dict[key] if len(args_dict[key]) >= 3 else exit("Error Report invalid, -erep requires minimum length of 3")
		
		if key == "errlog" and args_dict[key]:  # min length of 3
			output_dict["pipeErrorLogFile"] = args_dict[key] if len(args_dict[key]) >= 3 else exit("Error Logfile invalid, -elog requires minimum length of 3")

	# handle varbank error event case	
	if output_dict["event"].startswith("varbank"):
		
		# set otherType based on input event
		output_dict["otherType"] = "varbankTransfer"\
		if output_dict["event"].startswith("varbankTransfer")\
			else "varbankUploadDb"
		
		# add logfile to correct field
		# (bei pipeerror optional, bei varbank error pflicht)
		output_dict["errorLogFile"] = args_dict["errlog"]\
			if args_dict["errlog"] and len(args_dict["errlog"]) >= 3 and os.path.isfile(args_dict["errlog"])\
				else exit("Error Logfile invalid, -elog required min length of 3 AND has to be valid file.")

		# if error file was parsed previously, remove from output dict
		output_dict.pop("pipeErrorLogFile", None)

		# transfer error message to correct field
		output_dict["errorMessage"] = output_dict["pipeErrorMessage"]  # add new entry
		output_dict.pop("pipeErrorMessage", None)  # remove old message entry
		
		# adjust event
		output_dict["event"] = "otherError"

	
	return output_dict

def checkCompleteArgs(args_dict):
	'''
	Build Json file String for pipeCompleted event.
	Also extract uuid for building transfer URL later on.

	input: Dictionary of previously type checked arguments
	output: Json file String, uuid String
	'''

	# regex patterns for UTC time & uuId
	utc_regex = "[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z"
	uuidv4_regex ="^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-4[0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$"

	output_dict = {}

	# iterate args
	for key in args_dict:
	# event is already checked, directly transfer to output dict
		if key == "event":
			output_dict[key] = args_dict[key]
		
		# time is generated from script - no need to check
		if key == "utcTime":
			output_dict[key]=args_dict[key] 


		if key == "uuid":  # check uuid in v4 format
				output_dict[key] = args_dict[key] if args_dict[key] and re.search(uuidv4_regex, args_dict[key]) else exit("uuID invalid, please supply -uuid in uuid v4 format")
	
	# if event is varbank related: first, add other type based on input event, then adjust event 
	if output_dict["event"].startswith("varbank"):
		
		# add otherType based on inout event
		output_dict["otherType"] = "varbankTransfer"\
		if output_dict["event"].startswith("varbankTransfer")\
			else "varbankUploadDb"
	
		# adjust event
		output_dict["event"] = "otherCompleted"

	return output_dict

#########################
# Building Json Methods #
#########################
def buildPipeStartorUpdateJson(args_dict):
	'''
	Build json file String for pipeStarted event from previously type checked arguments.
	Arguments are transferred to Json file String with correct field names & nesting of data. 
	
	input: Dictionary of arguments to built json from
	output: Json file String
	'''
	lims_fields = ["prid", "sid", "aid", "pshort"]
	# dict for collecting
	json_dict = {}

	# transfer top level arguments
	json_dict['pipeUUID'] = args_dict["uuid"]
	json_dict['event'] = args_dict["event"]
	json_dict['utcTime'] = args_dict["utcTime"]
	if "host" in args_dict.keys(): json_dict['pipeHost'] = args_dict["host"] # req for start, optional in update events
	if "framew" in args_dict.keys(): json_dict['pipeFramework'] = args_dict["framew"]
	if "ptype" in args_dict.keys(): json_dict['pipeType'] = args_dict["ptype"]
	if "script" in args_dict.keys(): json_dict['pipeScript'] = args_dict["script"]
	if "pversion" in args_dict.keys(): json_dict['pipeVersion'] = args_dict["pversion"]
	if "runid" in args_dict.keys(): json_dict['nfRunId'] = args_dict["runid"]
	if "runname" in args_dict.keys(): json_dict['nfRunName'] = args_dict["runname"]
	if "psubtype" in args_dict.keys(): json_dict['pipeSubtype'] = args_dict["psubtype"]


	# create lims list entry only if all lims arguments are supplied
	if all([x in args_dict.keys() for x in lims_fields]):
		lims_entries = []
		single_lims_entry = {}
		single_lims_entry['projectId'] = int(args_dict["prid"])
		single_lims_entry['sampleId'] = int(args_dict["sid"])
		single_lims_entry['analysisId'] = int(args_dict["aid"])
		single_lims_entry['projectShortcut'] = args_dict["pshort"]

		# only add these entries if subtype is trio
		# check from parsed args b/c subtype gets converted during argument
		if parsed_args["psubtype"] == "trio_CHILD":
			single_lims_entry['trioContext'] = "child"
			if "motherSid" in args_dict.keys(): single_lims_entry['motherSid'] = args_dict["motherSid"]
			if "fatherSid" in args_dict.keys(): single_lims_entry['fatherSid'] = args_dict["fatherSid"]

		elif parsed_args["psubtype"] == "trio_MOTHER":
			single_lims_entry['trioContext'] = "mother"

		elif parsed_args["psubtype"] == "trio_FATHER":
			single_lims_entry['trioContext'] = "father"


		lims_entries.append(single_lims_entry)  # collect lims entries
		json_dict["lims"] = lims_entries  # write to json dict
	
	# create demult lims if ptype is demult
	elif "pipeType" in json_dict.keys() and json_dict['pipeType'] == "demult":
		demult_lims = {}
		if "runFolder" in args_dict.keys(): demult_lims['runFolder'] = args_dict["runFolder"]
		if "plateId" in args_dict.keys(): demult_lims['plateId'] = args_dict["plateId"]
		
		if len(demult_lims) > 0: # only transfer lims field if its not empty
			json_dict["lims"] = [demult_lims]



	## collect all available logfiles - if any were supplied
	if all([x in args_dict.keys() for x in ["logtype", "logpath"]]):
		log_files = []
		for i in range(len(args_dict["logtype"])):  # collect log files 1 by 1
			log_collect = {}
			log_collect["logType"] = args_dict["logtype"][i]
			log_collect["filePath"] = args_dict["logpath"][i]
			log_files.append(log_collect)  # collect logfiles
		json_dict["pipeLogFiles"] = log_files  # write list of parsed files to json dict

	# return json dumped version
	return json.dumps(json_dict), json_dict["pipeUUID"]

def buildErrorOrCompleteJson(args_dict):
	'''
	Build Json file String for pipeError and pipeCompleted events.
	Also extract uuid for building transfer URL later on.

	input: Dictionary of previously type checked arguments
	output: Json file String, uuid String
	'''

	uuid = args_dict["uuid"]  # extract uuid for PUT url construction
	args_dict.pop("uuid", None)  # remove from dict, not required in json

	# directly return json.dumps(args_dict) b/c fields already have correct name
	return json.dumps(args_dict), uuid

def buildJsonFromArgs(args_dict, event):

	if event in ["pipeStarted", "pipeUpdate"] :
		args_checked = checkPipeStartOrUpdateArgs(args_dict)
		json_file, uuid = buildPipeStartorUpdateJson(args_checked)
	
	elif event in ["varbankTransferStart", "varbankUploadStart"]:
		args_checked = checkOtherStartArgs(args_dict)
		json_file, uuid = buildErrorOrCompleteJson(args_checked)
		
	elif event in ["pipeError", "varbankTransferError", "varbankUploadError"]:
		args_checked = checkErrorArgs(args_dict)
		json_file, uuid = buildErrorOrCompleteJson(args_checked)

	elif event in ["pipeCompleted", "varbankTransferCompleted", "varbankUploadCompleted"]:
		args_checked = checkCompleteArgs(args_dict)
		json_file, uuid = buildErrorOrCompleteJson(args_checked)
	else:
		exit("Json build for event %s not implemented" % event)
	
	return json_file, uuid

#######################
# Submit JSON Methods #
#######################
def checkServerAvailability(hostname):
	'''
	Check server availability via ping

	input: hostname of server to be tested
	output: Bool whether server is available
	'''

	# remove server prefixes to solve ping issues
	hostname = hostname[8:] if hostname.startswith("https://") else hostname

	# if localhost: ping 127.0.0.1 (could be removed all together..)
	hostname = "127.0.0.1" if hostname.startswith("http://localhost") else hostname

	# test server availability w/ ping
	if os.system("ping -c 1 %s > /dev/null 2>&1 " % hostname) == 0:
		return True
	else:
		return False

def transferJsonToServer(transfer_method, json_file, host, x_auth_token, uuid):
	#TODO: use kwargs to remove uuid from being required
	'''
	Transfer input Json to Host and print data from server response.

	input: Method String for transfer (PUT/POST), Json String for transfer, Host String to transfer to,
			X-Auth token String for transfer, uuid String for URL construction (only required for PUT)
	output: None, only prints data from response
	'''

	global most_recent_transfer_status
	# header is always the same
	headers = {
	'Content-Type': 'application/json',
	'x-auth-token': x_auth_token,
	}

	# data is always json file
	data = json_file	

	# perform POST or PUT action
	if transfer_method == "POST":
		response = requests.post('%s/api/messages/pipe/' % host, headers=headers, data=data)
	
	elif transfer_method == "PUT":
		response = requests.put('%s/api/messages/pipe/%s' % (host, uuid), headers=headers, data=data)
	
	else:
		exit ("Unknown transfer method: %s" % transfer_method)


	
	# Print response data to console depending on transfer status
	############################
	if response.status_code == 200:  # success
		print("Transfer of %s data successful!" % \
			(json.loads(json_file)["event"]))  # first, print success
		most_recent_transfer_status = "success"

		try:  # avoid no response json error: try parsing, else dont parse
			response_data = response.json()
			print("-> transfer id: %s" %\
				(response_data["_id"]))
		except:
			print("-> Did not receive a response json")

	elif response.status_code == 400:  # fail
		print("Error while transferring %s data.." %\
			parsed_event) # first print fail info
		most_recent_transfer_status = "fail"
		try:  # then, try to parse json, if received: print message
			response_data = response.json()
			print("-> response: %s" %\
				(response_data["message"]))
		except:
			print("-> Did not receive a response json")

	else:  # catch unkonwn codes
		
		print("Unknown response code: %s" % (response.status_code))
		most_recent_transfer_status = "unknown"
		try:  # avoid no response json error: try parsing, else dont parse
			response_data = response.json()
			print("-> transfer id: %s" %\
				(response_data["_id"]))
			print("-> data received: %s" % (response_data))
		except:
			print("-> Did not receive a response json")
		exit()
		
def writeJsonToFallback(json_file, uuid, fallback_dir, hostname, submission_method):
	'''
	Writes input data to Fallback directory. Name of the File is the uuid of the submission.

	input: String resembling Json file, submission uuid,
			directory to write file to, hostname to later submit the fallback file to
	output: Nothing, only prints when file was written
	'''

	time = re.findall(utc_regex, json_file)[0]  # get time for filename

	file_name = "%s_%s" % (time, uuid)  # gemerate filename
	file_path = "%s/%s" % (fallback_dir, file_name)  # generate filepath

	with open(file_path, "w") as file:  # write file
		file.write(submission_method + "\n")
		file.write(hostname + "\n")
		file.write(json_file)
		file.close()

	print("Wrote file '%s' to fallback stack %s" % (file_name, fallback_dir))

def processFallback(fallback_dir):
	'''
	Process files from input fallback stack.
	Only files matching uuid regex will be sent. Sent files are deleted from disk afterwards.
	If host referenced in file is offline, file is not sent.

	input: directory to scan for files
	output: nothing..
	'''

	# make sure / @ end of dirname
	fallback_dir = fallback_dir if fallback_dir.endswith("/") else fallback_dir + "/"

	# Start info print
	print("Processing files from fallback stack at: %s" % fallback_dir)
	print("-----")

	# get files matching uuid regex from stack dir
	# python3: files = [x if re.search(uuidv4_regex, x) else print(x) for x in os.listdir(fallback_dir) ]  # only get uuidv4 file
	# python3: files = [x for x in files if x is not None]  # remove none entries
	files = [x for x in os.listdir(fallback_dir) if re.search(fallback_file_regex, x)]  # only get uuidv4 file
	files.sort()  # sort to be safe (should already be sorted from listdir)
	
	# only print unsuitable files if there are any
	unsuitable_files = [x for x in os.listdir(fallback_dir) if not re.search(fallback_file_regex, x)]
	if len(unsuitable_files) > 0:
		print("Following files not suitable for processing:\n")
		print("\n".join(unsuitable_files))
		print("-----\n")
	

	# setup loop vars
	received_token = False
	x_auth = None

	for file in files:  # files are named by the submission uuid
		uuid = re.findall(uuidv4_regex[1:], file)[0]  # get uuid from filename

		# get file content
		with open(fallback_dir + file, "r") as parse:
			content = parse.read().split("\n")
			parse.close()
		
		# map parsed content to vars
		transfer_method = content[0]
		host = content[1]
		json_file = content[2]

		if checkServerAvailability(host):

			# get only one token for fallback processing
			x_auth = x_auth if received_token else getXauthToken(host)
			
			# transfer data from file to server
			print("Transferring file %s..." % file)
			transferJsonToServer(transfer_method, json_file, host, x_auth, uuid)  # run transfer
			
			# check outcome of transfer via global variable
			if most_recent_transfer_status == "success":
				os.remove("%s/%s" % (fallback_dir, file))  # remove file from stack if transmission successful
				print("Removing file..\n")
			else:
				print("File transfer to host was unsuccessful: the file is not removed from fallback stack")
		else:
			print("File %s could not be sent.." % uuid)
			print("Host '%s' is not available" % host)
			print()

def checkFallbackForSameUUIDEvent(uuid, fallback_dir):
	fallback_uuids = [re.findall(uuidv4_regex[1:], x)[0] for x in os.listdir(fallback_dir) if re.search(uuidv4_regex[1:], x)] # get list of uuids in fallback stack
	return True if uuid in fallback_uuids else False
	
def handleGeneratedJson(json_file, uuid, host):
	
	# catch debug mode
	if str(args.debug) == "true":
		print("Json file:\n" +json_file )
		exit()

	# if uuid in fallback stack -> wirte 
	elif parsed_event in update_Events and checkFallbackForSameUUIDEvent(uuid, fallback_dir):
		print("Found files with same UUID on Fallback stack, writing to fallback stack..")

		# write to fallback
		writeJsonToFallback(json_file, uuid, fallback_dir, host, "PUT")  # write to fallback stack

	# check if host is available - if so: send json
	elif checkServerAvailability(host):
		# get x-auth token from environ variable
		x_auth = getXauthToken(host)
		# if event = pipeStarted, POST with uuid = None b/c not required for url building, else PUT w/ uuid
		transferJsonToServer("POST", json_file, host, x_auth, None) \
			if parsed_event == "pipeStarted" else \
				transferJsonToServer("PUT", json_file, host, x_auth, uuid)

	# host not available: write to fallback
	else:
		print("Host %s is not available, writing to fallback stack.." % host)
		
		# write fallback file with correct submission method, depending on inout even
		writeJsonToFallback(json_file, uuid, fallback_dir, host, "POST") \
			if parsed_event == "pipeStarted" else \
				writeJsonToFallback(json_file, uuid, fallback_dir, host, "PUT")  # write to fallback stack

##############
# Code Start #
##############
# regex patterns 
utc_regex = "[0-9]{4}-[01]{1}[0-9]{1}-[0-3]{1}[0-9]{1}T[0-2]{1}[0-9]{1}:[0-6]{1}[0-9]{1}:[0-6]{1}[0-9]{1}.[0-9]{3}Z"
uuidv4_regex ="^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-4[0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$"
fallback_file_regex = utc_regex+"_"+uuidv4_regex[1:]

# Parse Event & Fallback dir, check if both valid
###########################################################
parsed_event = str(args.event) if str(args.event) in valid_Events else exit("Please enter valid Pipeline Event (%s)" % ",  ".join(valid_Events))

# check fallback directory
fallback_dir = str(args.fallb)  # parse  
if not os.access(fallback_dir, os.F_OK): # if not valid - exit
	exit("Directory'%s' does not exist. Please supply an existing directory for fallback (-fall)." % fallback_dir)

# If event = Fallback, process Fallback else: parse args for Submission
#############################################################################
if parsed_event == "processFallback":
	processFallback(fallback_dir)
	exit()
else:
	# event is not processFallback: parse args
	parsed_args = args.__dict__
	parsed_args["utcTime"] = generateUtcTime() # add time
	host = checkIfhostValid(str(args.server))  # get host 


# Generate Json for Submission for pipestarted, pipeError and pipeCompleted
###############################################################################
json_file, uuid = buildJsonFromArgs(parsed_args, parsed_event)

# Handle Json, either Send or put to fallback
#################################################
handleGeneratedJson(json_file, uuid, host)