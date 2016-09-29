module Qnap
	class ApiError < StandardError
		attr_reader :uri, :response

		STATUS_CODES = [
			[ 0, "WFM2_FAIL",                        "Unknown error"],
			[ 1, "WFM2_DONE",                        "Success"],
			# [ 1, "WFM2_SUCCESS",                     "Success"],
			[ 2, "WFM2_FILE_EXIST",                  "File already exists"],
			[ 3, "WFM2_AUTH_FAIL",                   "Authentication Failure"],
			[ 4, "WFM2_PERMISSION_DENY",             "Permission Denied"],
			[ 5, "WFM2_FILE_NO_EXIST",               "File or folder does not exist"],
			# [ 5, "WFM2_SRC_FILE_NO_EXIST",           "File/folder does not exist"],
			[ 6, "WFM2_EXTRACTING",                  "FILE EXTRACTING"],
			[ 7, "WFM2_OPEN_FILE_FAIL",              "Failed to open file"],
			[ 8, "WFM2_DISABLE",                     "Web File Manager is not enabled"],
			[ 9, "WFM2_QUOTA_ERROR",                 "You have reached the disk quota limit"],
			[10, "WFM2_SRC_PERMISSION_DENY",         "You do not have permission to perform this action"],
			[11, "WFM2_DES_PERMISSION_DENY",         "You do not have permission to perform this action"],
			[12, "WFM2_ILLEGAL_NAME",                "Invalid character encountered: \"+=/\\:|*?<>;[]%,`'"],
			[13, "WFM2_EXCEED_ISO_MAX",              "The maximum number of allowed ISO shares is 256"],
			[14, "WFM2_EXCEED_SHARE_MAX",            "The maximum number of shares is going to be exceeded"],
			[15, "WFM2_NEED_CHECK",                  nil],
			[16, "WFM2_RECYCLE_BIN_NOT_ENABLE",      "Recycle bin is not enabled"],
			[17, "WFM2_CHECK_PASSWORD_FAIL",         "Enter password"],
			[18, "WFM2_VIDEO_TCS_DISABLE",           nil],
			[19, "WFM2_DB_FAIL",                     "The system is currently busy"],
			# [19, "WFM2_DB_QUERY_FAIL",               "The system is currently busy"],
			[20, "WFM2_PARAMETER_ERROR",             "There were input errors"],
			[21, "WFM2_DEMO_SITE",                   "Your files are now being transcoded"],
			[22, "WFM2_TRANSCODE_ONGOING",           "Your files are now being transcoded"],
			[23, "WFM2_SRC_VOLUME_ERROR",            "An error occurred in the source file"],
			[24, "WFM2_DES_VOLUME_ERROR",            "A write error has occurred at the destination"],
			[25, "WFM2_DES_FILE_NO_EXIST",           "The destination is unavailable"],
			[26, "WFM2_FILE_NAME_TOO_LONG",          "255 filename byte limit exceeded"],
			[27, "WFM2_FOLDER_ENCRYPTION",           "This folder has been encrypted"],
			[28, "WFM2_PREPARE",                     "Processing now"],
			[29, "WFM2_NO_SUPPORT_MEDIA",            "This file format is not supported"],
			[30, "WFM2_DLNA_QDMS_DISABLE",           "Please enable the DLNA Media Server"],
			[31, "WFM2_RENDER_NOT_FOUND",            "Cannot find any available DLNA devices"],
			[32, "WFM2_CLOUD_SERVER_ERROR",          "The SmartLink service is currently busy"],
			[33, "WFM2_NAME_DUP",                    "File or folder name already exists"],
			[34, "WFM2_EXCEED_SEARCH_MAX",           nil],
			[35, "WFM2_MEMORY_ERROR",                nil],
			[36, "WFM2_COMPRESSING",                 nil],
			[37, "WFM2_EXCEED_DAV_MAX",              nil],
			[38, "WFM2_UMOUNT_FAIL",                 nil],
			[39, "WFM2_MOUNT_FAIL",                  nil],
			[40, "WFM2_WEBDAV_ACCOUNT_PASSWD_ERROR", nil],
			[41, "WFM2_WEBDAV_SSL_ERROR",            nil],
			[42, "WFM2_WEBDAV_REMOUNT_ERROR",        nil],
			[43, "WFM2_WEBDAV_HOST_ERROR",           nil],
			[44, "WFM2_WEBDAV_TIMEOUT_ERROR",        nil],
			[45, "WFM2_WEBDAV_CONF_ERROR",           nil],
			[46, "WFM2_WEBDAV_BASE_ERROR",           nil],
		]

		def initialize(status_code, uri, response=nil)
			@uri = uri
			@response = response
			super STATUS_CODES[status_code.to_i].last(2).compact.join ' - '
		end
	end
end
