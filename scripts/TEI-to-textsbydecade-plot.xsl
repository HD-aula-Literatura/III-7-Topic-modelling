<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs xd txm" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:txm="http://textometrie.org/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="2.0">
    
    <xd:doc type="stylesheet">
        <xd:short>
            This stylesheet "TEI-to-textsbydecade-plot.xsl" serves to create a 
            bar chart showing the number of texts per decade in a corpus.
        </xd:short>
        <xd:detail>
            This stylesheet serves to create a bar chart showing the number
            of texts per decade in a corpus.
            
            As input format, the stylesheet expects the format that is
            internally generated in the tool TXM, when a corpus is imported
            with the method "TXT + CSV".
            
            This script can be executed with the TXM macro ExecXSL. How to call
            this script: In the TXM menu, select "Utilities" -> "xml" -> "ExecXSL",
            then pass the following parameters:
            
            XSLFile*: [PATH-TO-WORKING-DIRECTORY-ON-YOUR-COMPUTER]/TEI-to-textsbydecade-plot.xsl
            inputDirectory*: [PATH-TO-TXM-ON-YOUR-COMPUTER]/TXM-0.8.2/corpora/[NAME-OF-YOUR-CORPUS]/txm/[NAME-OF-YOUR-CORPUS]
            outputDirectory*: [PATH-TO-WORKING-DIRECTORY-ON-YOUR-COMPUTER]/out
            
            It produces an HTML file with a plot as output. For each input file, 
            there will also be an XML output file in the output directory,
            which can be ignored and deleted. 
            The html output file is stored in a folder "html", as a subfolder of 
            your selected working directory (where this XSLT file is in).
            
            It is expected that there is a metadata category called "decade"
            in the CSV metadata file of the corpus and that the values of 
            this metadata category are numbers with four digits (e.g. 1950).
            
            This stylesheet is free software; you can redistribute it and/or
            modify it under the terms of the GNU Lesser General Public
            License as published by the Free Software Foundation; either
            version 3 of the License, or (at your option) any later version.
            
            This stylesheet is distributed in the hope that it will be useful,
            but WITHOUT ANY WARRANTY; without even the implied warranty of
            MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
            Lesser General Public License for more details (available at
            http://www.gnu.org/licenses/lgpl.html).
        </xd:detail>
        <xd:author>Ulrike Henny-Krahmer</xd:author>
        <xd:copyright>GNU Lesser General Public License</xd:copyright>
    </xd:doc>
    
    <xsl:output method="html" media-type="text/html" encoding="UTF-8"/>
    
    <xsl:variable name="input-directory">
        <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/.]+$">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:variable>
    <xsl:variable name="output-directory">
        <xsl:analyze-string select="static-base-uri()" regex="^(.*)/([^/]+)\.[^/.]+$">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/><xsl:text>/html</xsl:text>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:variable>
    
    
    <xsl:template match="/">
        <!-- calculate this only once, for the first document in the corpus -->
        <xsl:variable name="id-this" select=".//tei:text/@id"/>
        <xsl:variable name="corpus" select="collection($input-directory)//tei:TEI"/>
        <xsl:variable name="id-first" select="$corpus[1]//tei:text/@id"/>
        <xsl:if test="$id-this = $id-first">
            <xsl:variable name="filename">textsbydecade</xsl:variable>
            <xsl:variable name="metadata" select="document(concat($input-directory,'/../../metadata.xml'))"/>
            <xsl:variable name="decades" select="$metadata//text/entry[@id='decade']/@value/xs:integer(substring(.,1,3))"/>
            <xsl:variable name="decade-min" select="min($decades)"/>
            <xsl:variable name="decade-max" select="max($decades)"/>
            <xsl:result-document href="{$output-directory}/{$filename}.html">
                <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
                <html>
                    <head>
                        <!-- Load plotly.js into the DOM -->
                        <script src='https://cdn.plot.ly/plotly-2.14.0.min.js'></script>
                        <title>Texts by decade</title>
                    </head>
                <body>
                    <div id='myDiv'><!-- Plotly chart will be drawn inside this DIV --></div>
                    <script>
                        var data = [
                        {
                        x: [<xsl:for-each select="$decade-min to $decade-max">
                            <xsl:value-of select="."/><xsl:text>0</xsl:text>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        y: [<xsl:for-each select="$decade-min to $decade-max">
                            <xsl:value-of select="count($metadata//text[entry[@id='decade']/@value = concat(xs:string(current()),'0')])"/>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>],
                        type: 'bar'
                        }
                        ];
                        
                        var layout = {
                            width: 550,
                            height: 400,
                            title: "Número de textos por década en el corpus", // 'Number of texts per decade in the corpus'
                            xaxis: {
                                title: "década", // decade
                                autotick: false,
                                type: "category"
                            },
                            yaxis: {
                                title: "número de textos" // number of texts
                            }
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
                </html>
            </xsl:result-document>
        </xsl:if>
        <warning>Result file written to <xsl:value-of select="$output-directory"/></warning>
    </xsl:template>
    
        
    
    
</xsl:stylesheet>