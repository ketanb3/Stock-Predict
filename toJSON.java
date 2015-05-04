import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;


import org.json.simple.JSONObject;

//import org.json.JSONArray;
//import org.json.JSONException;
//import org.json.JSONObject;


public class toJSON {
	
	@SuppressWarnings("unchecked")
	public static void main(String[] args) throws ArrayIndexOutOfBoundsException
	{
		BufferedReader br = null;
		BufferedWriter bw = null;
		JSONObject obj = new JSONObject();
		
		
		try
		{
			br = new BufferedReader(new FileReader("C:\\Ket Data\\Big Data\\Final Project\\BigWSJData.txt"));
			
			String currLine;
			//bw = new BufferedWriter(new FileWriter("jsonWSJ", true));
			BufferedWriter file = new BufferedWriter(new FileWriter("appleNews.txt"));
			while((currLine = br.readLine())!= null)
			{
				if ((currLine.toLowerCase().contains("apple")) || (currLine.toLowerCase().contains("ipad")) || (currLine.toLowerCase().contains("ipod")) || (currLine.toLowerCase().contains("ipay")) || (currLine.toLowerCase().contains("iphone")) )
				{
				String[] tokens = currLine.split("	");
				
				obj.put("Date", tokens[0].substring(10,20));
				obj.put("Time", tokens[0].substring(21,29));
				obj.put("Headline",tokens[1].substring(10));
				obj.put("Content", tokens[2].substring(9));
				
				file.write(obj.toJSONString());
				file.flush();
				file.newLine();
				}
				else continue;
			}
			
			file.close();
			
		}
		catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally
 	   {
 	      //Closing the BufferedWriter
 	      try
 	      {
 	         if (br != null) 
 	         {
 	            //br.flush();
 	           br.close();
 	         }
 	      } 
 	      catch (IOException ex) 
 	      {
 	         ex.printStackTrace();
 	      }
 	   }
		
		

	}

}
