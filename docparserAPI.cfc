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
		if(structKeyExists(httpResponse,"filecontent") && isJSON(trim(httpResponse.fileContent))){
			var fileContent = deserializeJSON(httpResponse.fileContent);
			structInsert(httpResponse, "fileContent", fileContent, true);
		}
		return httpResponse;
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
	
	function documentUpload(string localPath, string parserId) hint="https://dev.docparser.com/?json##import-document"{
		var httpService = getHttpService("document/upload/" & parserId);
		httpService.setMethod("post");
		httpService.setMultipart("YES");
		httpService.addParam(type="file", file=localPath, name="file");
		return sendHTTP(httpService);
	}
	
	function documentFetch(string urlString, string parserId) hint="https://dev.docparser.com/?json##import-document"{
		var httpService = getHttpService("document/fetch/" & parserId);
		httpService.setMethod("post");
		httpService.addParam(type="url", name="url", value=urlString);
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