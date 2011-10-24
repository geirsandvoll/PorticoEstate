<!-- item  -->

<xsl:template match="data" xmlns:php="http://php.net/xsl">

<xsl:call-template name="yui_booking_i18n"/>
<div class="identifier-header">
<h1><img src="{img_go_home}" /> 
		<xsl:value-of select="php:function('lang', 'Procedure')" />
</h1>
</div>

<div class="yui-content">
		<div id="details">
			<form action="#" method="post">
				<input type="hidden" name="id" value = "{value_id}">
				</input>
				<dl class="proplist-col">
					<dt>
						<label for="title"><xsl:value-of select="php:function('lang','Procedure title')" /></label>
					</dt>
					<dd>
					<xsl:choose>
						<xsl:when test="editable">
							<input type="text" name="title" id="title" value="{procedure/title}" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="procedure/title" />
						</xsl:otherwise>
					</xsl:choose>
					</dd>
					<dt>
						<label for="purpose"><xsl:value-of select="php:function('lang','Procedure purpose')" /></label>
					</dt>
					<dd>
					<xsl:choose>
						<xsl:when test="editable">
							<textarea id="purpose" name="purpose" rows="5" cols="60"><xsl:value-of select="procedure/purpose" disable-output-escaping="yes"/></textarea>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="procedure/purpose" disable-output-escaping="yes"/>
						</xsl:otherwise>
					</xsl:choose>
					</dd>
					<dt>
						<label for="responsibility"><xsl:value-of select="php:function('lang','Procedure responsibility')" /></label>
					</dt>
					<dd>
					<xsl:choose>
						<xsl:when test="editable">
							<textarea id="responsibility" name="responsibility" rows="5" cols="60"><xsl:value-of select="procedure/responsibility" /></textarea>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="procedure/responsibility" />
						</xsl:otherwise>
					</xsl:choose>
					</dd>
					<dt>
						<label for="description"><xsl:value-of select="php:function('lang','Procedure description')" /></label>
					</dt>
					<dd>
					<xsl:choose>
						<xsl:when test="editable">
							<textarea id="description" name="description" rows="5" cols="60"><xsl:value-of select="procedure/description" disable-output-escaping="yes"/></textarea>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="procedure/description" disable-output-escaping="yes"/>
						</xsl:otherwise>
					</xsl:choose>
					</dd>
					<dt>
						<label for="start_date"><xsl:value-of select="php:function('lang','Procedure start date')" /></label>
					</dt>
					<dd>
						<xsl:value-of disable-output-escaping="yes" select="start_date"/>
					</dd>
					<dt>
						<label for="end_date"><xsl:value-of select="php:function('lang','Procedure end date')" /></label>
					</dt>
					<dd>
						<xsl:value-of disable-output-escaping="yes" select="end_date"/>
					</dd>
					<dt>
						<label for="reference"><xsl:value-of select="php:function('lang','Procedure Reference')" /></label>
					</dt>
					<dd>
					<xsl:choose>
						<xsl:when test="editable">
							<input type="text" name="reference" id="reference" value="{procedure/reference}"  />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="procedure/reference" />
						</xsl:otherwise>
					</xsl:choose>
					</dd>	
					<dt>
					<label for="attachment"><xsl:value-of select="php:function('lang','Procedure Attachment')" /></label>
					</dt>
					<dd>
					<xsl:choose>
						<xsl:when test="editable">
							<input type="text" name="attachment" id="attachment" value="{procedure/attachment}"  />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="procedure/attachment" />
						</xsl:otherwise>
					</xsl:choose>
					</dd>			
				</dl>
				
				<div class="form-buttons">
					<xsl:choose>
						<xsl:when test="editable">
							<xsl:variable name="lang_save"><xsl:value-of select="php:function('lang', 'save')" /></xsl:variable>
							<xsl:variable name="lang_revisit"><xsl:value-of select="php:function('lang', 'revisit')" /></xsl:variable>
							<xsl:variable name="lang_cancel"><xsl:value-of select="php:function('lang', 'cancel')" /></xsl:variable>
							<input type="submit" name="save_procedure" value="{$lang_save}" title = "{$lang_save}" />
							<input type="submit" name="revisit_procedure" value="{$lang_revisit}" title = "{$lang_revisit}" />
							<input type="submit" name="cancel_procedure" value="{$lang_cancel}" title = "{$lang_cancel}" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="lang_edit"><xsl:value-of select="php:function('lang', 'edit')" /></xsl:variable>
							<input type="submit" name="edit_procedure" value="{$lang_edit}" title = "{$lang_edit}" />
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</form>
						
		</div>
	</div>
</xsl:template>