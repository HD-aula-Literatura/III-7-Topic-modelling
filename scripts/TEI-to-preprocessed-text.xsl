<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" 
    xmlns:txm="http://textometrie.org/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="2.0">
    
    <xd:doc type="stylesheet">
        <xd:short>
            This stylesheet "TEI-to-preprocessed-text.xsl" serves to create a 
            preprocessed text from a linguistically annotated text to prepare
            it for futher text analysis. The text can be segmented, lemmas and 
            words with certain parts of speech can be selected.
        </xd:short>
        <xd:detail>
            This stylesheet "TEI-to-preprocessed-text.xsl" serves to create a 
            preprocessed text from a linguistically annotated text to prepare
            it for futher text analysis. The text can be segmented, lemmas and 
            words with certain parts of speech can be selected.
            
            For topic modeling, for example, it can be useful to use shorter 
            segments (if the whole texts are very long, for example in the case 
            of novels) and to only keep the noun lemmas of the texts.
            
            As input format, the stylesheet expects the TEI format that is
            internally generated in the tool TXM, when a corpus is imported
            with the method "TXT + CSV" and subsequently annotated with the
            TreeTagger during the import process.
            
            This script can be executed with the TXM macro ExecXSL. How to call
            this script: In the TXM menu, select "Utilities" -> "xml" -> "ExecXSL",
            then pass the following parameters:
            
            XSLFile*: [PATH-TO-WORKING-DIRECTORY-ON-YOUR-COMPUTER]/TEI-to-segmented-lemmatext.xsl
            inputDirectory*: [PATH-TO-TXM-ON-YOUR-COMPUTER]/TXM-0.8.2/corpora/[NAME-OF-YOUR-CORPUS]/txm/[NAME-OF-YOUR-CORPUS]
            outputDirectory*: [PATH-TO-WORKING-DIRECTORY-ON-YOUR-COMPUTER]/out
            
            It produces a set of plain text files in .txt format. If the texts
            are segmented, several files with segments for each input file in TEI 
            are created. Otherwise there will be one .txt output file for each text.
            For each input file, there  will also be an XML output file in 
            the output directory, which can be ignored and deleted. 
            All the txt output files are stored in a folder "txt_preprocessed", 
            as a subfolder of your selected working directory (where this XSLT file is in).
            
            The length of the segments (in number of word tokens) can be set 
            in the parameter $seglength below. The default value is a segment
            length of 1000 word tokens. If this parameter is set to "all",
            the texts will not be segmented.
            
            The names of the part of speech tags to be selected can be set
            in the parameter $postags below. These need to correspond to the 
            TreeTagger tagset in the relevant language. The default for this 
            script are the tags for nouns in Spanish, except personal nouns.
            If this parameter is set to "all", words with all types of 
            PoS tags are kept.
            
            The parameter $lemma indicates if lemmas should be chosen for 
            the output text ("yes") or the original word forms ("no").
            
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
    
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    
    <!-- change the following parameter value to change the segment length in word tokens;
    if the parameter has the value "all", the whole texts are kept and not segmented -->
    <xsl:param name="seglength">1000</xsl:param>
    
    <!-- change the following parameter value to select other PoS tags;
    if the parameter has the value "all", the words will not be filtered by PoS tags -->
    <xsl:param name="postags" select="'NC+NMEA+NMON+ADJ+VLadj+VLfin+VLger+VLinf'"/>
    
    <!-- change the following parameter to indicate if lemmas ("yes") or the original word forms ("no")
    should be chosen for the preprocessed text. By default, lemmas are chosen. -->
    <xsl:param name="lemmas" select="'yes'"/>
        
    
    <xsl:variable name="output-directory">
        <xsl:analyze-string select="static-base-uri()" regex="^(.*)/([^/]+)\.[^/.]+$">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/><xsl:text>/txt_preprocessed</xsl:text>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:variable>
    
    <xsl:variable name="filename">
        <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/.]+$">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:variable>
    
    
    <xsl:template match="/">
        <xsl:choose>
            <!-- do not segment the texts -->
            <xsl:when test="$seglength = 'all'">
                <xsl:result-document href="{$output-directory}/{$filename}.txt">
                    <xsl:call-template name="postags">
                        <xsl:with-param name="nodeset" select=".//w"/>
                    </xsl:call-template>
                </xsl:result-document>
            </xsl:when>
            <!-- do segment the texts -->
            <xsl:otherwise>
                <xsl:for-each-group select="(.//w)" group-by="(position()-1) idiv xs:integer($seglength)">
                    <xsl:result-document href="{$output-directory}/{$filename}§{format-number(position(),'000')}.txt">
                        <xsl:call-template name="postags">
                            <xsl:with-param name="nodeset" select="current-group()"/>
                        </xsl:call-template>
                    </xsl:result-document>
                </xsl:for-each-group>
            </xsl:otherwise>
        </xsl:choose>
        <warning>Result files written to <xsl:value-of select="$output-directory"/></warning>
    </xsl:template>
    
    
    <xsl:template name="lemmas">
        <xsl:choose>
            <!-- do not select lemmas, but original word forms -->
            <xsl:when test="$lemmas = 'no'">
                <xsl:value-of select="txm:form"/>
            </xsl:when>
            <!-- do select lemmas -->
            <xsl:otherwise>
                <xsl:value-of select="txm:ana[@type='#eslemma']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="lb">
        <xsl:if test="position()!=last()"></xsl:if>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    
    <xsl:template name="postags">
        <xsl:param name="nodeset"/>
        <xsl:choose>
            <!-- do not filter by pos tags -->
            <xsl:when test="$postags='all'">
                <xsl:for-each select="$nodeset">
                    <xsl:call-template name="lemmas"/>
                    <xsl:call-template name="lb"/>
                </xsl:for-each>
            </xsl:when>
            <!-- do filter by pos tags -->
            <xsl:otherwise>
                <xsl:for-each select="$nodeset[txm:ana[@type='#espos']=tokenize($postags,'\+')]">
                    <xsl:call-template name="lemmas"/>
                    <xsl:call-template name="lb"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
</xsl:stylesheet>