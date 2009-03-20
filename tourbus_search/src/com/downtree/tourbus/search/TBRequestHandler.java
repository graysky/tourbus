/*
 * LICENSE
 */
package com.downtree.tourbus.search;

import java.net.URL;
import java.util.List;

import org.apache.lucene.search.Query;
import org.apache.lucene.search.Sort;
import org.apache.solr.core.SolrCore;
import org.apache.solr.core.SolrException;
import org.apache.solr.core.SolrInfoMBean;
import org.apache.solr.request.SolrQueryRequest;
import org.apache.solr.request.SolrQueryResponse;
import org.apache.solr.request.SolrRequestHandler;
import org.apache.solr.request.StandardRequestHandler;
import org.apache.solr.search.DocList;
import org.apache.solr.search.DocSet;
import org.apache.solr.search.QueryParsing;
import org.apache.solr.search.SolrCache;
import org.apache.solr.util.CommonParams;
import org.apache.solr.util.NamedList;
import org.apache.solr.util.SolrPluginUtils;
import org.apache.solr.util.StrUtils;

/**
 * Mostly taken from Solr's StandardRequestHandler.
 * - Added the ability to filter documents by location.
 * - Removed highlighting because we'll never use it.
 *
 */
public class TBRequestHandler implements SolrRequestHandler, SolrInfoMBean
{
    long m_numRequests;
    long m_numErrors;
    long m_filterCacheHits;
    long m_filterCacheMisses;

    /** shorten the class referneces for utilities */
    private static class U extends SolrPluginUtils
    {
        /* :NOOP */
    }
    
    /** parameters garnered from config file */
    protected final CommonParams params = new CommonParams();

    public void init(NamedList args)
    {
        params.setValues(args);
    }

    public void handleRequest(SolrQueryRequest req, SolrQueryResponse rsp)
    {
        m_numRequests++;

        // TODO: test if lucene will accept an escaped ';', otherwise
        // we need to un-escape them before we pass to QueryParser
        try
        {
            String sreq = req.getQueryString();
            String debug = U.getParam(req, CommonParams.DEBUG_QUERY, params.debugQuery);
            String defaultField = U.getParam(req, CommonParams.DF, params.df);

            // find fieldnames to return (fieldlist)
            String fl = U.getParam(req, CommonParams.FL, params.fl);
            int flags = 0;
            if (fl != null)
            {
                flags |= U.setReturnFields(fl, rsp);
            }

            if (sreq == null)
                throw new SolrException(400, "Missing queryString");
            
            List<String> commands = StrUtils.splitSmart(sreq, ';');
            String qs = commands.size() >= 1 ? commands.get(0) : "";
            
            Query query = QueryParsing.parseQuery(qs, defaultField, req.getSchema());

            // If the first non-query, non-filter command is a simple sort on an
            // indexed field, then
            // we can use the Lucene sort ability.
            Sort sort = null;
            if (commands.size() >= 2)
            {
                QueryParsing.SortSpec sortSpec = QueryParsing.parseSort(commands.get(1), req.getSchema());
                if (sortSpec != null)
                {
                    sort = sortSpec.getSort();
                    // ignore the count for now... it's currently only
                    // controlled by start & limit on req
                    // count = sortSpec.getCount();
                }
            }

            // TB stuff
            DocSet filter = null;
            
            String latStr = U.getParam(req, "lat", null);
            String longStr = U.getParam(req, "long", null);
            String radiusStr = U.getParam(req, "radius", null);
            String docType = U.getParam(req, "docType", null);
            if (latStr != null && longStr != null && radiusStr != null && docType != null)
            {
                String key = getFilterCacheKey(latStr, longStr, radiusStr, docType);
                
                SolrCache cache = req.getSearcher().getCache("locationFilterCache");
                filter = (DocSet) cache.get(key);
                if (filter == null)
                {
                    LocationFilter locFilter = 
                        new LocationFilter(docType, Double.parseDouble(latStr),
                                           Double.parseDouble(longStr), Double.parseDouble(radiusStr));
                    filter = req.getSearcher().convertFilter(locFilter);
                    cache.put(key, filter);
                    m_filterCacheMisses++;
                }
                else
                {
                    m_filterCacheHits++;
                }
            }
            
            DocList results = 
                    req.getSearcher().getDocList(query, filter, sort, req.getStart(), req.getLimit());
            rsp.add(null, results);

            try
            {
                NamedList dbg = U.doStandardDebug(req, qs, query, results, params);
                if (null != dbg)
                    rsp.add("debug", dbg);
            }
            catch (Exception e)
            {
                SolrException.logOnce(SolrCore.log, "Exception durring debug", e);
                rsp.add("exception_during_debug", SolrException.toStr(e));
            }
        }
        catch (SolrException e)
        {
            rsp.setException(e);
            m_numErrors++;
            return;
        }
        catch (Exception e)
        {
            SolrException.log(SolrCore.log, e);
            rsp.setException(e);
            m_numErrors++;
            return;
        }
    }

    protected String getFilterCacheKey(String latitude, String longitude, String radius, String docType)
    {
        return latitude + longitude + radius + docType;
    }
    
    // ////////////////////// SolrInfoMBeans methods //////////////////////

    public String getName()
    {
        return StandardRequestHandler.class.getName();
    }

    public String getVersion()
    {
        return SolrCore.version;
    }

    public String getDescription()
    {
        return "The tourb.us request handler";
    }

    public Category getCategory()
    {
        return Category.QUERYHANDLER;
    }

    public String getSourceId()
    {
        return "";
    }

    public String getSource()
    {
        return "";
    }

    public URL[] getDocs()
    {
        return null;
    }

    public NamedList getStatistics()
    {
        NamedList lst = new NamedList();
        lst.add("requests", m_numRequests);
        lst.add("errors", m_numErrors);
        lst.add("filterCacheHits", m_filterCacheHits);
        lst.add("filterCacheMisses", m_filterCacheMisses);
        return lst;
    }

}
