package edu.ucla.cs.cs144;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.lucene.document.Field;
import org.apache.lucene.document.Document;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.index.IndexWriter;

import java.io.IOException;


public class HelloLucene {

    public HelloLucene() {
    }
 
    private IndexWriter indexWriter = null;
    public IndexWriter getIndexWriter(boolean create) throws IOException {
        if (indexWriter == null) {
        //    indexWriter = new IndexWriter("~/index_1",new StandardAnalyzer(),create);
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
	ResultSet rs = stmt.executeQuery("select id, mainCategory, subCategory from podcast where id=215925465");
 	try{   	
 	getIndexWriter(true);
	while(rs.next()){
	System.out.println(rs.getString("id")+":"+rs.getString("mainCategory")+rs.getString("subCategory"));
       	//indexCategory(rs.getString("id"),rs.getString("mainCategory")+rs.getString("subCategory"));
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

    public static void main(String args[]) {
        HelloLucene idx = new HelloLucene();
        try{
			idx.rebuildIndexes();
        }
		catch(SQLException ex){
            System.out.println("SQLException caught");
            System.out.println("---");
            while ( ex != null ){
                System.out.println("Message   : " + ex.getMessage());
                System.out.println("SQLState  : " + ex.getSQLState());
                System.out.println("ErrorCode : " + ex.getErrorCode());
                System.out.println("---");
                ex = ex.getNextException();
            }
        }
    }   
}
