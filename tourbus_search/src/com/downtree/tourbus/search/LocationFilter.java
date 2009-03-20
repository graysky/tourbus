/*
 * LICENSE
 */
package com.downtree.tourbus.search;

import java.io.IOException;
import java.util.BitSet;

import org.apache.lucene.document.Document;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.index.TermDocs;
import org.apache.lucene.search.Filter;
import org.apache.solr.core.SolrCore;
import org.apache.solr.core.SolrException;

/**
 * A port of our ruby LocationFilter class
 */
public class LocationFilter extends Filter
{
    private String m_type;
    private double m_centerLat;
    private double m_centerLong;
    private double m_radius;
    
    private static final double DEG2RAD = Math.PI / 180;
    private static final int EARTH_RADIUS = 3963;
    
    public LocationFilter(String type, double centerLat, double centerLong, double radius)
    {
        super();
       
        m_type = type;
        m_centerLat = centerLat * DEG2RAD;
        m_centerLong = centerLong * DEG2RAD;
        m_radius = radius;
    }

    @Override
    public BitSet bits(IndexReader reader) throws IOException
    {
        BitSet bits = new BitSet(reader.maxDoc());
        
        TermDocs docs = reader.termDocs(new Term("ferret_class", m_type));
        while (docs.next())
        {
            Document doc = reader.document(docs.doc());
            String value = doc.get("latitude");
            if (value == null)
                continue;

            try
            {
                double latitude = Double.parseDouble(value) * DEG2RAD;
                double longitude = Double.parseDouble(doc.get("longitude")) * DEG2RAD;
            
                double x = (Math.sin(latitude) * Math.sin(m_centerLat)) + (Math.cos(latitude) * Math.cos(m_centerLat) * Math.cos(longitude - m_centerLong));
                
                double distance = 0;
                if (x > -1 && x < 1)
                {
                    distance = Math.acos(x) * EARTH_RADIUS;
                }
                
                if (distance <= m_radius)
                {
                    bits.set(docs.doc());
                }
            }
            catch (Exception e)
            {
                SolrException.logOnce(SolrCore.log, "Error in location filter", e);
                continue;
            }
        }
        
        return bits;
    }

}
