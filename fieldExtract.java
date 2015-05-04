import org.json.JSONArray;
import org.json.JSONException;
//import org.json.simple.JSONArray;
//import org.json.simple.JSONObject;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.nio.charset.Charset;

public class fieldExtract {
	
	private static String readAll(Reader rd) throws IOException {
	    StringBuilder sb = new StringBuilder();
	    int cp;
	    while ((cp = rd.read()) != -1) {
	      sb.append((char) cp);
	    }
	    return sb.toString();
	  }
	
	public static JSONObject readJsonFromUrl(String url) throws IOException, JSONException {
	    InputStream is = new URL(url).openStream();
	    try {
	      BufferedReader rd = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
	      String jsonText = readAll(rd);
	      JSONObject json = new JSONObject(jsonText);
	      return json;
	    } finally {
	      is.close();
	    }
	  }
	public static void main(String[] args)
	{
		
		JSONObject json;
		BufferedWriter bufferedWriter = null;
		try {
			
			bufferedWriter = new BufferedWriter(new FileWriter("headlineWsj.txt", true));
			//reading JSON object data from URL
			json = readJsonFromUrl("http://betawebapi.dowjones.com/fintech/articles/api/v1/instrument/goog");
			//Reading JSON Array object 
			JSONArray dataJsonArray = json.getJSONArray("Headlines");
			for(int i=0; i<dataJsonArray.length(); i++) {
			   JSONObject dataObj = dataJsonArray.getJSONObject(i);
			   //Extracting and writing date and time object
			   JSONObject dateTime = dataObj.getJSONObject("CreateTimestamp");
			   String DT = dateTime.getString("Value");
			   bufferedWriter.write("DateTime: "+DT+"	");
			   
			   //Extracting Headline object
			   String headline = dataObj.getString("Headline");
			   bufferedWriter.write("Headline: "+headline+"	");
			   
			   //extracting and writing main content data
			   
			   JSONObject Abs = dataObj.getJSONObject("Abstract");
			   //JSONArray abstractArray = dataObj.getJSONArray("Abstract");
			   //for(int j=0; j<abstractArray.length();j++){
				   //JSONObject absObject = abstractArray.getJSONObject(j);
			   JSONObject inAbs = Abs.getJSONObject("ABSTRACT");
			   JSONObject para = inAbs.getJSONObject("PARAGRAPH");
			   //String text = para.getString("#text");
			   //JSONObject mainText = para.getJSONObject("#text");
			   
			   if(para.has("#text")){
				   String newsText = para.getString("#text").toString();
				   bufferedWriter.write("Content: "+newsText);
				 
			   }else{
				   
				   String newsText = "no main content";
				     bufferedWriter.write("Content: "+newsText);
			   }
			   //}
			   //Adding new line for next Array element
			   bufferedWriter.newLine();
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally
 	   {
 	      //Closing the BufferedWriter
 	      try
 	      {
 	         if (bufferedWriter != null) 
 	         {
 	            bufferedWriter.flush();
 	            bufferedWriter.close();
 	         }
 	      } 
 	      catch (IOException ex) 
 	      {
 	         ex.printStackTrace();
 	      }
 	   }
		
	}
	
	

}
