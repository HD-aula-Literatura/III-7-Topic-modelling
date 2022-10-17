<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="2.0">
    
    <xd:doc type="stylesheet">
        <xd:short>
            This stylesheet serves to extract plain text from XML files,
            which were created by exporting PDF files with the Adobe Acrobat Reader.
        </xd:short>
        <xd:author>Ulrike Henny-Krahmer</xd:author>
        <xd:copyright>GNU Lesser General Public License</xd:copyright>
    </xd:doc>
    
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:value-of select="."/>
    </xsl:template>
    
    
</xsl:stylesheet>