package edu.ucla.cs.cs144;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import java.io.IOException;

import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopScoreDocCollector;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.RAMDirectory;
import org.apache.lucene.util.Version;
public class HelloLucene {

    public HelloLucene() {
    }
 
    private IndexWriter indexWriter = null;
    private IndexSearcher searcher = null;
//    private QueryParser categoryParser = null;
    private Directory index = null;
    public IndexWriter getIndexWriter(boolean create) throws IOException {
	if(create){        
	  if (indexWriter == null) {
	  StandardAnalyzer analyzer = new StandardAnalyzer(Version.LUCENE_40);
	  index = new RAMDirectory();
	  IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_40, analyzer);
          indexWriter = new IndexWriter(index,config);
        }
     }
        return indexWriter;
   }    
   
    public void closeIndexWriter() throws IOException {
        if (indexWriter != null) {
            indexWriter.close();
        }
   }

    public void indexCategory(String id, String category) throws IOException {   //TO-DO we need a struct for id and category
    IndexWriter writer = getIndexWriter(false);
    Document doc = new Document();
    doc.add(new Field("id", id, TextField.TYPE_STORED));
    doc.add(new Field("category", category, TextField.TYPE_STORED));
  //  doc.add(new Field("id",id,Field.Store.YES,Field.Index.NO));
  //  doc.add(new Field("category",category,Field.Store.YES,Field.Index.TOKENIZED));
    writer.addDocument(doc);
  }

    public void rebuildIndexes() throws SQLException {
        Connection conn = null;
        // create a connection to the database to retrieve Items from MySQL
	try {
	    conn = DbManager.getConnection(true);
	} catch (SQLException ex) {
	    System.out.println(ex);
	}
	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery("select id, mainCategory, subCategory from podcast");
 	try{   	
 	getIndexWriter(true);
	while(rs.next()){
	//System.out.println(rs.getString("id")+":"+rs.getString("mainCategory")+rs.getString("subCategory"));
       	indexCategory(rs.getString("id"),rs.getString("mainCategory")+rs.getString("subCategory"));
	}	
	closeIndexWriter();
	}catch (Exception e)
	{
	  System.out.println("Exception caught");
	}
        // close the database connection
	try {
	    conn.close();
	} catch (SQLException ex) {
	    System.out.println(ex);
	}
    }   

    ////////////////////////////////////////////
public void search() throws IOException, ParseException{     
   // 2. query 区域 本地 needs to be more specific
    String[] categoryArray = {"健康","儿童与家庭","商业","喜剧","宗教与精神生活","政府与组织","教育","新闻及政治","游戏与爱好","电视与电影","社会与文化","科学与医学","科技","艺术","运动与消遣","音乐","两性关系","投资","基督教","专业","业余","个人日记","中小学","伊斯兰教","佛教","健美与营养","全国","其他","其它游戏","励志自助","区域","医药","历史","另类保健","名胜与旅行","哲学","商业新闻","培训","大中院校","小工具","户外","播客发布","教育科技","文学","时尚美容","本地","汽车","爱好","社会科学","科技新闻","管理和营销","精神生活","美食","职业","自然科学","表演艺术","视频游戏","视频艺术","设计","语言教程","软件技巧","非营利","高等教育"};
    String[] weightArray = {"1.3","1","1","100","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1"};
   // String[] categoryArray = {"健康","儿童与家庭"};
  //  String[] weightArray = {"1","1"};
    String querystr = "";//"(表演艺术)^1.5 (视频)^2";
    for(int i=0; i<categoryArray.length;i++)
    {
	querystr+="("+categoryArray[i]+")^"+weightArray[i]+" ";	
    }
    // the "title" arg specifies the default field to use
    // when no field is explicitly specified in the query.
    StandardAnalyzer analyzer = new StandardAnalyzer(Version.LUCENE_40);
    Query categoryParser = new QueryParser(Version.LUCENE_40, "category", analyzer).parse(querystr);

    // 3. search
    int hitsPerPage = 50;
    IndexReader reader = DirectoryReader.open(index);
/*
int num = reader.numDocs();
for ( int i = 0; i < num; i++)
{
 
        Document d = reader.document( i);
        System.out.println( "d=" +d);
}
reader.close();
*/
    searcher = new IndexSearcher(reader);
    TopScoreDocCollector collector = TopScoreDocCollector.create(hitsPerPage, true);
    searcher.search(categoryParser, collector);
    ScoreDoc[] hits = collector.topDocs().scoreDocs;
    
    // 4. display results
    System.out.println("Found " + hits.length + " hits.");
    for(int i=0;i<hits.length;++i) {
      int docId = hits[i].doc;
      Document d = searcher.doc(docId);
      System.out.println((i + 1) + ". " + d.get("id") + "\t" + d.get("category"));
    }
   
    // reader can only be closed when there
    // is no need to access the documents any more.
    reader.close();
    /////////////////////////////////////////////////////////////
}
    public static void main(String args[]) {
        HelloLucene idx = new HelloLucene();
        try{
	    idx.rebuildIndexes();
	    idx.search();
        }
		//catch(SQLException ex){
           // System.out.println("SQLException caught");
           // System.out.println("---");
           // while ( ex != null ){
           //     System.out.println("Message   : " + ex.getMessage());
           //     System.out.println("SQLState  : " + ex.getSQLState());
           //     System.out.println("ErrorCode : " + ex.getErrorCode());
           //     System.out.println("---");
           //     ex = ex.getNextException();
           // }
	  catch(Exception ex){
	    System.out.println(ex);
	  }
        //}
    }   
}
