<!-- $Id: choose_control_items.xsl 8267 2011-12-11 12:27:18Z sigurdne $ -->

<xsl:template match="data" xmlns:php="http://php.net/xsl">

<div id="main_content" class="medium">
	
	<h1>Utførelse av kontroll: <xsl:value-of select="control/title"/></h1>
	<xsl:choose>
		<xsl:when test="type = 'component'">
			<h2><xsl:value-of select="component_array/xml_short_desc"/></h2>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="type = 'component'">
					<h2><xsl:value-of select="component_array/xml_short_desc"/></h2>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="location_level = 1">
							<h2>Eiendom: <xsl:value-of select="location_array/loc1_name"/></h2>
						</xsl:when>
						<xsl:otherwise>
								<h2>Bygg: <xsl:value-of select="location_array/loc2_name"/></h2>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
		
	<xsl:call-template name="check_list_tab_menu" />

	<div id="view_cases">

		<h3 class="box_header ext">Registrer sak/måling</h3>
		<div class="tab_item active ext">
		
		<div class="expand_menu"><div class="expand_all">Vis alle</div><div class="collapse_all focus">Skjul alle</div></div>
		
		<ul class="control_groups">
			<xsl:for-each select="control_groups_with_items_array">
			<xsl:choose>
				<xsl:when test="control_items/child::node()">
					<li>
						<h3><xsl:value-of select="control_group/group_name"/></h3>				
						<ul class="expand_list">
							<xsl:for-each select="control_items">
								<li>
									<h4><img src="controller/images/arrow_right.png" /><span><xsl:value-of select="title"/></span></h4>	
										<xsl:choose>
											<xsl:when test="type = 'control_item_type_1'">
												<form class="frm_register_case expand_item" action="index.php?menuaction=controller.uicase.register_case&amp;phpgw_return_as=json" method="post">
													<xsl:variable name="control_item_id"><xsl:value-of select="id"/></xsl:variable>
													<input type="hidden" name="control_item_id" value="{$control_item_id}" /> 
													<input name="check_list_id" type="hidden"><xsl:attribute name="value"><xsl:value-of select="//check_list/id"/></xsl:attribute></input>
												    <input name="status" type="hidden" value="0" />
													<input name="type" type="hidden" value="control_item_type_1" />
													    
											       	<div>
											        	<label class="comment">Beskrivelse av sak</label>
													    <textarea name="case_descr">
															<xsl:value-of select="comment"/>
														</textarea>
													</div>
												 	<input type="submit" class="btn not_active" name="save_control" value="Lagre sak" />
												</form>
											</xsl:when>
											<xsl:when test="type = 'control_item_type_2'">
											<form class="frm_register_case expand_item" action="index.php?menuaction=controller.uicase.register_case&amp;phpgw_return_as=json" method="post">
												<xsl:variable name="control_item_id"><xsl:value-of select="id"/></xsl:variable>
													<input type="hidden" name="control_item_id" value="{$control_item_id}" /> 
													<input name="check_list_id" type="hidden"><xsl:attribute name="value"><xsl:value-of select="//check_list/id"/></xsl:attribute></input>
													<input name="type" type="hidden" value="control_item_type_2" />
												
													<div class="row">
														<label>Status</label>
														<select name="status">
															<option value="0" SELECTED="SELECTED">Åpen</option>
															<option value="1" >Lukket</option>
															<option value="2" >Venter på tilbakemelding</option>
												   		</select>
												   </div>
											       <div class="row">
											         <label class="comment">Registrer målingsverdi</label>
											           <input>
													      <xsl:attribute name="name">measurement</xsl:attribute>
													      <xsl:attribute name="type">text</xsl:attribute>
													      <xsl:attribute name="value">
													      	<xsl:value-of select="measurement"/>
													      </xsl:attribute>
													    </input>
											       </div>
											       <div class="row">
												         <label class="comment">Beskrivelse av sak</label>
												         <textarea name="case_descr">
															<xsl:value-of select="comment"/>
														 </textarea>
												   </div>
											       <xsl:variable name="lang_save"><xsl:value-of select="php:function('lang', 'register_error')" /></xsl:variable>
												   <input type="submit" name="save_control" value="Lagre måling" class="not_active" title="{$lang_save}" />
												</form>
											</xsl:when>
											<xsl:when test="type = 'control_item_type_3'">
												<form class="frm_register_case expand_item" action="index.php?menuaction=controller.uicase.register_case&amp;phpgw_return_as=json" method="post">
													<xsl:variable name="control_item_id"><xsl:value-of select="id"/></xsl:variable>
													<input type="hidden" name="control_item_id" value="{$control_item_id}" /> 
													<input name="check_list_id" type="hidden"><xsl:attribute name="value"><xsl:value-of select="//check_list/id"/></xsl:attribute></input>
													<input name="type" type="hidden" value="control_item_type_3" />
												
													<div class="row">
														<label>Status</label>
														<select name="status">
															<option value="0" SELECTED="SELECTED">Åpen</option>
															<option value="1" >Lukket</option>
															<option value="2" >Venter på tilbakemelding</option>
												   		</select>
												   </div>
											       <div class="row">
											         <label class="comment">Velg verdi fra liste</label>
											         	<select name="option_value">
											         		<xsl:for-each select="options_array"> 
																<option>
																	<xsl:attribute name="value"><xsl:value-of select="option_value"/></xsl:attribute>
																	<xsl:value-of select="option_value"/>
																 </option>	
															</xsl:for-each>
												   		</select>
											       </div>
											       <div class="row">
												         <label class="comment">Beskrivelse av sak</label>
												         <textarea name="case_descr">
															<xsl:value-of select="comment"/>
														 </textarea>
												   </div>
											       <xsl:variable name="lang_save"><xsl:value-of select="php:function('lang', 'register_error')" /></xsl:variable>
												   <input type="submit" name="save_control" value="Lagre sak/måling" class="not_active" title="{$lang_save}" />
												</form>
											</xsl:when>
											<xsl:when test="type = 'control_item_type_4'">
												<form class="frm_register_case expand_item" action="index.php?menuaction=controller.uicase.register_case&amp;phpgw_return_as=json" method="post">
													<xsl:variable name="control_item_id"><xsl:value-of select="id"/></xsl:variable>
													<input type="hidden" name="control_item_id" value="{$control_item_id}" /> 
													<input name="check_list_id" type="hidden"><xsl:attribute name="value"><xsl:value-of select="//check_list/id"/></xsl:attribute></input>
													<input name="type" type="hidden" value="control_item_type_4" />
												
													<div class="row">
														<label>Status</label>
														<select name="status">
															<option value="0" SELECTED="SELECTED">Åpen</option>
															<option value="1" >Lukket</option>
															<option value="2" >Venter på tilbakemelding</option>
												   		</select>
												   </div>
											       <div class="row">
											         <label class="comment">Velg verdi fra liste</label>
											         	<select name="option_value">
											         		<xsl:for-each select="options_array"> 
																<option>
																	<xsl:attribute name="value"><xsl:value-of select="option_value"/></xsl:attribute>
																	<xsl:value-of select="option_value"/>
																 </option>	
															</xsl:for-each>
												   		</select>
											       </div>
											       <div class="row">
												         <label class="comment">Beskrivelse av sak</label>
												         <textarea name="case_descr">
															<xsl:value-of select="comment"/>
														 </textarea>
												   </div>
											       <xsl:variable name="lang_save"><xsl:value-of select="php:function('lang', 'register_error')" /></xsl:variable>
												   <input type="submit" name="save_control" value="Lagre sak/måling" class="not_active" title="{$lang_save}" />
												</form>
											</xsl:when>
										</xsl:choose>	
									
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:when>
				<xsl:otherwise>
					<li class="list_item">
						<h3><xsl:value-of select="control_group/group_name"/></h3>
						<div>Ingen kontrollpunkt for denne gruppen</div>
					</li>
				</xsl:otherwise>
			</xsl:choose>
			</xsl:for-each>
		</ul>
	</div>
</div>
</div>
</xsl:template>
