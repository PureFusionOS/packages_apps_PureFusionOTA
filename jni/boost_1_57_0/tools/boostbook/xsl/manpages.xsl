<?xml version="1.0" encoding="utf-8"?><!--
   Copyright (c) 2002 Douglas Gregor <doug.gregor -at- gmail.com>
  
   Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE_1_0.txt or copy at
   http://www.boost.org/LICENSE_1_0.txt)
  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <!-- Import the man pages stylesheet -->
    <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl" />

    <xsl:param name="generate.manifest" select="1" />
    <xsl:param name="manifest">man.manifest</xsl:param>

    <xsl:template match="literallayout">
        <xsl:text>&#10;.nf&#10;</xsl:text>
        <xsl:apply-templates />
        <xsl:text>&#10;.fi&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="para|simpara|remark" mode="list">
        <xsl:variable name="foo">
            <xsl:apply-templates />
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="literallayout">
                <xsl:copy-of select="$foo" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space($foo)" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#10;</xsl:text>
        <xsl:if test="following-sibling::para or following-sibling::simpara or
                  following-sibling::remark">
            <!-- Make sure multiple paragraphs within a list item don't -->
            <!-- merge together.                                        -->
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="build.refentry.filename">
        <xsl:param name="node" select="." />
        <xsl:variable name="section" select="$node/refmeta/manvolnum" />
        <xsl:variable name="name" select="$node/refnamediv/refname[1]" />
        <xsl:value-of select="concat('man', $section, '/',
                                 translate(normalize-space($name), 
				           '&lt;&gt;', '__'), 
                                 '.', $section)" />

    </xsl:template>

    <xsl:template match="refentry" mode="manifest">
        <xsl:call-template name="build.refentry.filename" />
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="//refentry">
                <xsl:apply-templates select="//refentry" />
                <xsl:if test="$generate.manifest=1">
                    <xsl:call-template name="write.text.chunk">
                        <xsl:with-param name="filename" select="$manifest" />
                        <xsl:with-param name="content">
                            <xsl:value-of select="$manifest" />
                            <xsl:text>&#10;</xsl:text>
                            <xsl:apply-templates mode="manifest" select="//refentry" />
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>No refentry elements!</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="refentry">
        <xsl:variable name="section" select="refmeta/manvolnum" />
        <xsl:variable name="name" select="refnamediv/refname[1]" />

        <!-- standard man page width is 64 chars; 6 chars needed for the two
             (x) volume numbers, and 2 spaces, leaves 56 -->
        <xsl:variable name="twidth" select="(56 - string-length(refmeta/refentrytitle)) div 2" />

        <xsl:variable name="reftitle" select="substring(refmeta/refentrytitle, 1, $twidth)" />

        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="refentryinfo/title">
                    <xsl:value-of select="refentryinfo/title" />
                </xsl:when>
                <xsl:when test="../referenceinfo/title">
                    <xsl:value-of select="../referenceinfo/title" />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="date">
            <xsl:choose>
                <xsl:when test="refentryinfo/date">
                    <xsl:value-of select="refentryinfo/date" />
                </xsl:when>
                <xsl:when test="../referenceinfo/date">
                    <xsl:value-of select="../referenceinfo/date" />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="productname">
            <xsl:choose>
                <xsl:when test="refentryinfo/productname">
                    <xsl:value-of select="refentryinfo/productname" />
                </xsl:when>
                <xsl:when test="../referenceinfo/productname">
                    <xsl:value-of select="../referenceinfo/productname" />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="write.text.chunk">
            <xsl:with-param name="filename">
                <xsl:call-template name="build.refentry.filename" />
            </xsl:with-param>
            <xsl:with-param name="content">
                <xsl:text>.\"Generated by db2man.xsl. Don't modify this, modify the source.
                    .de Sh \" Subsection
                    .br
                    .if t .Sp
                    .ne 5
                    .PP
                    \fB\\$1\fR
                    .PP
                    ..
                    .de Sp \" Vertical space (when we can't use .PP)
                    .if t .sp .5v
                    .if n .sp
                    ..
                    .de Ip \" List item
                    .br
                    .ie \\n(.$>=3 .ne \\$3
                    .el .ne 3
                    .IP "\\$1" \\$2
                    ..
                    .TH "
                </xsl:text>
                <xsl:value-of
                    select="translate($reftitle,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
                <xsl:text>"</xsl:text>
                <xsl:value-of select="refmeta/manvolnum[1]" />
                <xsl:text>"</xsl:text>
                <xsl:value-of select="normalize-space($date)" />
                <xsl:text>" "</xsl:text>
                <xsl:value-of select="normalize-space($productname)" />
                <xsl:text>" "</xsl:text>
                <xsl:value-of select="$title" />
                <xsl:text>"
                </xsl:text>
                <xsl:apply-templates />
                <xsl:text>&#10;</xsl:text>

                <!-- Author section -->
                <xsl:choose>
                    <xsl:when test="refentryinfo//author">
                        <xsl:apply-templates mode="authorsect" select="refentryinfo" />
                    </xsl:when>
                    <xsl:when test="/book/bookinfo//author">
                        <xsl:apply-templates mode="authorsect" select="/book/bookinfo" />
                    </xsl:when>
                    <xsl:when test="/article/articleinfo//author">
                        <xsl:apply-templates mode="authorsect" select="/article/articleinfo" />
                    </xsl:when>
                </xsl:choose>

            </xsl:with-param>
        </xsl:call-template>
        <!-- Now generate stub include pages for every page documented in
             this refentry (except the page itself) -->
        <xsl:for-each select="refnamediv/refname">
            <xsl:if test=". != $name">
                <xsl:call-template name="write.text.chunk">
                    <xsl:with-param name="filename"
                        select="concat(normalize-space(.), '.', $section)" />
                    <xsl:with-param name="content" select="concat('.so man',
	      $section, '/', $name, '.', $section, '&#10;')" />
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
