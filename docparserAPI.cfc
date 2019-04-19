component hint="https://dev.docparser.com/?json##introduction"{
	
	//Requires the API key from Docparser, and returns a copy of this CFC for your dependency injection
	function init(string key){
		variables.apiKey = key;
		variables.baseUrl = "https://api.docparser.com/v1/";
		return this;
	}
	
	//Generates Raw Request
	private function getHttpService(urlPart) hint="https://dev.docparser.com/?json##authentication"{
		var httpService = new http(method="get", url=variables.baseUrl & urlPart, authType="BASIC");
		httpService.addParam(type="header", name="Authorization", value="Basic " & variables.apiKey);
		return httpService;
	}
	
	//Sends Raw Request and does basic parse on response
	private function sendHTTP(httpService){
		var httpResponse = httpService.send().getPrefix();
		//Adobe Coldfusion does not allow you to edit the struct from http.send(), but Lucee does
		//Adobe Coldfusion also does not allow you to structcopy() it.
		//So the solution is to do a loop and copy all variables yourself
		var newHttpResponse = structNew();
		for(var key in httpResponse){
			structInsert(newHttpResponse,key,httpResponse[key],true);
		}
		if(structKeyExists(newHttpResponse,"Filecontent") && isJSON(trim(newHttpResponse.filecontent))){
			var fileContent = deserializeJSON(newHttpResponse.fileContent);
			structInsert(newHttpResponse, "Filecontent", fileContent, true);
		}
		return newHttpResponse;
	}
	
	//All further functions are the API endpoints
	function ping() hint="https://dev.docparser.com/?json##authentication"{
		var httpService = getHttpService("ping");
		return sendHTTP(httpService);
	}
	
	function listParsers() hint="https://dev.docparser.com/?json##parsers"{
		var httpService = getHttpService("parsers");
		return sendHTTP(httpService);
	}
	
	function documentUpload(string localPath, string parserId, string remoteId="") hint="https://dev.docparser.com/?json##import-document"{
		var httpService = getHttpService("document/upload/" & parserId);
		httpService.setMethod("post");
		httpService.setMultipart("YES");
		httpService.addParam(type="file", file=localPath, name="file");
		if(len(remoteId)){
			httpService.addParam(type="formfield", name="remote_id", value=remoteId);	
		}
		return sendHTTP(httpService);
	}
	
	function documentFetch(string urlString, string parserId, string remoteId="") hint="https://dev.docparser.com/?json##import-document"{
		var httpService = getHttpService("document/fetch/" & parserId);
		httpService.setMethod("post");
		httpService.setMultipart("YES"); //Fixes a bug where a URL that has things that need to be URL encoded, would get un-url-encoded when sent to the remote server
		httpService.addParam(type="formfield", name="url", value=urlString);
		if(len(remoteId)){
			httpService.addParam(type="formfield", name="remote_id", value=remoteId);
		}
		return sendHTTP(httpService);
	}
	
	function resultsList(string parserId, string format="object") hint="https://dev.docparser.com/?json##list7"{
		var httpService = getHttpService("results/" & parserId);
		httpService.addParam(type="url", name="format", value=format);
		return sendHTTP(httpService);
	}
	
	function resultsGet(string parserId, string documentId, string format="object") hint="https://dev.docparser.com/?json##get"{
		var httpService = getHttpService("results/" & parserId & "/" & documentId);
		httpService.addParam(type="url", name="format", value=format);
		return sendHTTP(httpService);
	}
}