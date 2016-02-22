<func:function name="phpgw:conditional">
	<xsl:param name="test"/>
	<xsl:param name="true"/>
	<xsl:param name="false"/>

	<func:result>
		<xsl:choose>
			<xsl:when test="$test">
				<xsl:value-of select="$true"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$false"/>
			</xsl:otherwise>
		</xsl:choose>
	</func:result>
</func:function>

<xsl:template match="data">
	<xsl:choose>
		<xsl:when test="datatable_name">
			<h3>
				<xsl:value-of select="datatable_name"/>
			</h3>
		</xsl:when>
	</xsl:choose>
	<xsl:call-template name="datatable" />
</xsl:template>


<xsl:template name="datatable">
	<script type="text/javascript">
		var number_of_toolbar_items = 0;
		var filter_selects = {};
	</script>
	<xsl:call-template name="jquery_phpgw_i18n"/>
	<xsl:apply-templates select="form" />
	<div id="list_flash">
		<xsl:call-template name="msgbox"/>
	</div>
	<div id="message" class='message'/>
	<xsl:apply-templates select="datatable"/>
	<xsl:apply-templates select="form/list_actions"/>
</xsl:template>


<xsl:template match="toolbar" xmlns:php="http://php.net/xsl">
	<style id='toggle-box-css' type='text/css' scoped='scoped'>
		.toggle-box {
		display: none;
		}

		.toggle-box + label {
		cursor: pointer;
		display: block;
		font-weight: bold;
		line-height: 21px;
		margin-bottom: 5px;
		}

		.toggle-box + label + #toolbar {
		display: none;
		margin-bottom: 10px;
		}

		.toggle-box:checked + label + #toolbar {
		display: block;
		}

		.toggle-box + label:before {
		background-color: #4F5150;
		-webkit-border-radius: 10px;
		-moz-border-radius: 10px;
		border-radius: 10px;
		color: #FFFFFF;
		content: "+";
		display: block;
		float: left;
		font-weight: bold;
		height: 20px;
		line-height: 20px;
		margin-right: 5px;
		text-align: center;
		width: 20px;
		}

		.toggle-box:checked + label:before {
		content: "\2212";
		}
	</style>
	<div id="active_filters"></div>

	<input class="toggle-box" id="header1" type="checkbox" />
	<label for="header1">
		<xsl:value-of select="php:function('lang', 'toolbar')"/>
	</label>

	<div id="toolbar">
		<!--xsl:if test="item/text and normalize-space(item/text)"-->
		<xsl:if test="item">
			<table id="toolbar_table" class="pure-table pure-table-horizontal">
				<thead>
					<tr>
						<th>
							<xsl:value-of select="php:function('lang', 'name')"/>
						</th>
						<th>
							<xsl:value-of select="php:function('lang', 'item')"/>
						</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="item">
						<script type="text/javascript">
							number_of_toolbar_items += 1;
						</script>

						<tr>
							<xsl:variable name="filter_key" select="concat('filter_', name)"/>
							<xsl:variable name="filter_key_name" select="concat(concat('filter_', name), '_name')"/>
							<xsl:variable name="filter_key_id" select="concat(concat('filter_', name), '_id')"/>
							<td>
								<xsl:if test="name">
									<label>
										<xsl:attribute name="for">
											<xsl:value-of select="phpgw:conditional(not(name), '', name)"/>
										</xsl:attribute>
										<xsl:value-of select="phpgw:conditional(not(text), '', text)"/>
									</label>
								</xsl:if>
							</td>
							<xsl:choose>
								<xsl:when test="type = 'date-picker'">
									<td valign="top">
										<div>
											<input id="filter_{name}" name="filter_{name}" value="{value}" type="text"></input>
										</div>
									</td>
								</xsl:when>
								<xsl:when test="type = 'autocomplete'">
									<td class="auto">
										<div class="auto">
											<input id="filter_{name}_name" name="filter_{name}_name" type="text">
												<xsl:attribute name="value">
													<xsl:value-of select="../../../filters/*[local-name() = $filter_key_name]"/>
												</xsl:attribute>
											</input>
											<input id="filter_{name}_id" name="filter_{name}_id" type="hidden">
												<xsl:attribute name="value">
													<xsl:value-of select="../../../filters/*[local-name() = $filter_key_id]"/>
												</xsl:attribute>
											</input>
											<div id="filter_{name}_container"/>
										</div>
										<script type="text/javascript">
											$(document).ready(function() {
											var app = "<xsl:value-of select="app"/>";
											var name = "<xsl:value-of select="name"/>";
											var ui = "<xsl:value-of select="ui"/>";
											var depends = false;
											var filter_depends = "";
											var filter_selected = "";
											<xsl:if test="depends">
												depends = "<xsl:value-of select="depends"/>";
												//filter_depends = $('#filer_'+depends+'_id').val();
												$("#filter_"+depends+"_name").on("autocompleteselect", function(event, i){
												var filter_select = i.item.value;
												filter_depends = i.item.value;
												if (filter_select != filter_selected){
												if (filter_depends) {
													<![CDATA[
															JqueryPortico.autocompleteHelper('index.php?menuaction=booking.ui'+ui+'.index&phpgw_return_as=json&filter_'+depends+'_id='+filter_depends+'&',
																									'filter_'+name+'_name', 'filter_'+name+'_id', 'filter_'+name+'_container');
													]]>
												}
												oTable.dataTableSettings[0]['ajax']['data']['filter_'+name+'_id'] = "";
												$('#filter_'+name+'_name').val('');
												$('#filter_'+name+'_id').val('');
												filter_selected = filter_select;
												}
												});
												$("#filter_"+depends+"_name").on("keyup", function(){
												if ($(this).val() == ''){
												filter_depends = false;
												if (!filter_depends) {
															<![CDATA[
																JqueryPortico.autocompleteHelper('index.php?menuaction=booking.ui'+ui+'.index&phpgw_return_as=json&',
																									'filter_'+name+'_name', 'filter_'+name+'_id', 'filter_'+name+'_container');
															]]>
												}
												filter_selected = "";
												oTable.dataTableSettings[0]['ajax']['data']['filter_'+name+'_id'] = "";
												$('#filter_'+name+'_name').val('');
												$('#filter_'+name+'_id').val('');
												}
												});
											</xsl:if>
											if (filter_depends) {
													<![CDATA[
														JqueryPortico.autocompleteHelper('index.php?menuaction=booking.ui'+ui+'.index&phpgw_return_as=json&filter_'+depends+'_id='+filter_depends+'&',
																							'filter_'+name+'_name', 'filter_'+name+'_id', 'filter_'+name+'_container');
													]]>
											}else{
													<![CDATA[
														JqueryPortico.autocompleteHelper('index.php?menuaction=booking.ui'+ui+'.index&phpgw_return_as=json&',
																							'filter_'+name+'_name', 'filter_'+name+'_id', 'filter_'+name+'_container');
													]]>
											}
											});
										</script>
									</td>
								</xsl:when>
								<xsl:when test="type = 'filter'">
									<td valign="top">
										<xsl:variable name="name">
											<xsl:value-of select="name"/>
										</xsl:variable>
										<script type="text/javascript">
											filter_selects['<xsl:value-of select="text"/>'] = '<xsl:value-of select="$name"/>';
										</script>
										<select id="{$name}" name="{$name}" width="250" style="width: 250px">
											<xsl:for-each select="list">
												<xsl:variable name="id">
													<xsl:value-of select="id"/>
												</xsl:variable>
												<xsl:choose>
													<xsl:when test="id = 'NEW'">
														<option value="{$id}" selected="selected">
															<xsl:value-of select="name"/>
														</option>
													</xsl:when>
													<xsl:otherwise>
														<xsl:choose>
															<xsl:when test="selected = 'selected'">
																<option value="{$id}" selected="selected">
																	<xsl:value-of select="name"/>
																</option>
															</xsl:when>
															<xsl:when test="selected = '1'">
																<option value="{$id}" selected="selected">
																	<xsl:value-of select="name"/>
																</option>
															</xsl:when>
															<xsl:otherwise>
																<option value="{$id}">
																	<xsl:value-of select="name"/>
																</option>
															</xsl:otherwise>
														</xsl:choose>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:for-each>
										</select>
									</td>
								</xsl:when>
								<xsl:when test="type = 'link'">
									<td valign="top">
										<input type="button" class="pure-button pure-button-primary">
											<xsl:choose>
												<xsl:when test="onclick">
													<xsl:attribute name="onclick">
														<xsl:value-of select="onclick"/>
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="onclick">javascript:window.open('<xsl:value-of select="href"/>', "_self");</xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:attribute name="value">
												<xsl:value-of select="value"/>
											</xsl:attribute>
										</input>
									</td>
								</xsl:when>
								<xsl:when test="type = 'hidden'">
									<td valign="top">
										<input>
											<xsl:attribute name="type">
												<xsl:value-of select="phpgw:conditional(not(type), '', type)"/>
											</xsl:attribute>
											<xsl:attribute name="id">
												<xsl:value-of select="phpgw:conditional(not(id), '', id)"/>
											</xsl:attribute>
											<xsl:attribute name="name">
												<xsl:value-of select="phpgw:conditional(not(name), '', name)"/>
											</xsl:attribute>
											<xsl:attribute name="value">
												<xsl:value-of select="phpgw:conditional(not(value), '', value)"/>
											</xsl:attribute>
										</input>
									</td>
								</xsl:when>
								<xsl:when test="type = 'label'">
									<td valign="top">
										<label>
											<xsl:attribute name="id">
												<xsl:value-of select="phpgw:conditional(not(id), '', id)"/>
											</xsl:attribute>
										</label>
									</td>
								</xsl:when>
								<xsl:otherwise>
									<td valign="top">
										<input id="innertoolbar">
											<xsl:attribute name="type">
												<xsl:value-of select="phpgw:conditional(not(type), '', type)"/>
											</xsl:attribute>
											<xsl:attribute name="name">
												<xsl:value-of select="phpgw:conditional(not(name), '', name)"/>
											</xsl:attribute>
											<xsl:attribute name="onclick">
												<xsl:value-of select="phpgw:conditional(not(onClick), '', onClick)"/>
											</xsl:attribute>
											<xsl:attribute name="value">
												<xsl:value-of select="phpgw:conditional(not(value), '', value)"/>
											</xsl:attribute>
											<xsl:attribute name="href">
												<xsl:value-of select="phpgw:conditional(not(href), '', href)"/>
											</xsl:attribute>
											<xsl:attribute name="class">
												<xsl:value-of select="phpgw:conditional(not(class), '', class)"/>
											</xsl:attribute>
										</input>
									</td>
								</xsl:otherwise>
							</xsl:choose>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</div>
</xsl:template>

<xsl:template match="form/list_actions">
	<form id="list_actions_form" method="POST">
		<!-- Form action is set by javascript listener -->
		<div id="list_actions" class='yui-skin-sam'>
			<table cellpadding="0" cellspacing="0">
				<tr>
					<xsl:for-each select="item">
						<td valign="top">
							<input id="innertoolbar">
								<xsl:attribute name="type">
									<xsl:value-of select="phpgw:conditional(not(type), '', type)"/>
								</xsl:attribute>
								<xsl:attribute name="name">
									<xsl:value-of select="phpgw:conditional(not(name), '', name)"/>
								</xsl:attribute>
								<xsl:attribute name="onclick">
									<xsl:value-of select="phpgw:conditional(not(onClick), '', onClick)"/>
								</xsl:attribute>
								<xsl:attribute name="value">
									<xsl:value-of select="phpgw:conditional(not(value), '', value)"/>
								</xsl:attribute>
								<xsl:attribute name="href">
									<xsl:value-of select="phpgw:conditional(not(href), '', href)"/>
								</xsl:attribute>
							</input>
						</td>
					</xsl:for-each>
				</tr>
			</table>
		</div>
	</form>
</xsl:template>

<xsl:template match="form">
	<div id="queryForm">
		<!--xsl:attribute name="method">
			<xsl:value-of select="phpgw:conditional(not(method), 'GET', method)"/>
		</xsl:attribute>
		<xsl:attribute name="action">
			<xsl:value-of select="phpgw:conditional(not(action), '', action)"/>
		</xsl:attribute-->
		<xsl:apply-templates select="toolbar"/>
	</div>
	<!--form id="update_table_dummy" method='POST' action='' >
	</form-->
</xsl:template>

<xsl:template match="datatable">
	<xsl:call-template name="top-toolbar" />
	<xsl:call-template name="datasource-definition" />
	<xsl:call-template name="end-toolbar" />
</xsl:template>

<xsl:template name="top-toolbar">
	<div class="toolbar-container">
		<div class="toolbar" >
			<form class="pure-form pure-form-stacked">
				<div class="pure-g">
					<div class="pure-u-1-3">
						<xsl:apply-templates select="//datatable/workorder_data" />
					</div>
					<div class="pure-u-2-3">
						<xsl:for-each select="//top-toolbar/fields/field">
							<xsl:choose>
								<xsl:when test="type='button'">
									<button id="{id}" type="{type}" class="pure-button pure-button-primary">
										<xsl:value-of select="value"/>
									</button>
								</xsl:when>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</div>
			</form>
		</div>
	</div>
</xsl:template>

<xsl:template name="end-toolbar">
	<div class="toolbar-container">
		<div class="toolbar">
			<form class="pure-form pure-form-stacked">
				<div class="pure-g">
					<div class="pure-u-1">
						<xsl:for-each select="//end-toolbar/fields/field">
							<xsl:choose>
								<xsl:when test="type = 'date-picker'">
									<td valign="top">
										<div>
											<input id="filter_{name}" name="filter_{name}" type="text"></input>
										</div>
									</td>
								</xsl:when>
								<xsl:when test="type='button'">
									<button id="{id}" type="{type}" class="pure-button pure-button-primary" onclick="{action}">
										<xsl:value-of select="value"/>
									</button>
								</xsl:when>
								<xsl:when test="type='label'">
									<xsl:value-of select="value"/>
								</xsl:when>
								<xsl:otherwise>
									<input id="{id}" type="{type}" name="{name}" value="{value}">
										<xsl:if test="type = 'checkbox' and checked = '1'">
											<xsl:attribute name="checked">checked</xsl:attribute>
										</xsl:if>
									</input>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</div>
			</form>
		</div>
	</div>
</xsl:template>

<xsl:template name="datasource-definition">
	<table id="datatable-container" class="display cell-border compact responsive no-wrap" width="100%">
		<thead>
			<xsl:for-each select="//datatable/field">
				<xsl:choose>
					<xsl:when test="hidden">
						<xsl:if test="hidden =0">
							<th>
								<xsl:value-of select="label"/>
							</th>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<th>
							<xsl:value-of select="label"/>
						</th>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</thead>
		<tfoot>
			<tr>
				<xsl:for-each select="//datatable/field">
					<xsl:choose>
						<xsl:when test="hidden">
							<xsl:if test="hidden =0">
								<th>
									<xsl:value-of select="value_footer"/>
								</th>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<th>
								<xsl:value-of select="value_footer"/>
							</th>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</tr>
		</tfoot>
	</table>
	<form id="custom_values_form" name="custom_values_form"></form>
	<script>
		var columns = [
		<xsl:for-each select="//datatable/field">
			{
			data: "<xsl:value-of select="key"/>",
			<xsl:if test="className">
				<xsl:choose>
					<xsl:when test="className='right' or className='center'">
						<xsl:if test="className ='right'">
							class:	'dt-right',
						</xsl:if>
						<xsl:if test="className ='center'">
							class:	'dt-center',
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						class:	"<xsl:value-of select="className"/>",
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			orderable:		<xsl:value-of select="phpgw:conditional(not(sortable = 0), 'true', 'false')"/>,
			<xsl:choose>
				<xsl:when test="hidden">
					<xsl:if test="hidden =0">
						visible: true,
					</xsl:if>
					<xsl:if test="hidden =1">
						class:			'none', //FIXME - virker ikke...'responsive' plukker den fram igjen
						visible: false,
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					visible: true,
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="formatter">
				render: function (dummy1, dummy2, oData) {
				try {
				var ret = <xsl:value-of select="formatter"/>("<xsl:value-of select="key"/>", oData);
				}
				catch(err) {
				return err.message;
				}
				return ret;
				},
			</xsl:if>
			<xsl:choose>
				<xsl:when test="dir !=''">
					dir: "<xsl:value-of select="dir"/>",
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="editor">
					<xsl:if test="editor =0">
						editor:	false,
					</xsl:if>
					<xsl:if test="editor =1">
						editor:	true,
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					editor:	false,
				</xsl:otherwise>
			</xsl:choose>
			defaultContent:	"<xsl:value-of select="defaultContent"/>"
			}<xsl:value-of select="phpgw:conditional(not(position() = last()), ',', '')"/>
		</xsl:for-each>
		];
		<![CDATA[
		JqueryPortico.columns = [];
		for(i=0;i < columns.length;i++)
		{
			if ( columns[i]['visible'] == true )
			{
				JqueryPortico.columns.push(columns[i]);
			}
		}
			// console.log(JqueryPortico.columns);
		]]>
	</script>


	<script type="text/javascript" class="init">
		var lang_ButtonText_columns = "<xsl:value-of select="php:function('lang', 'columns')"/>";

		var oTable = null;
		$(document).ready(function() {
		var ajax_url = '<xsl:value-of select="source"/>';
		var download_url = '<xsl:value-of select="download"/>';
		var exclude_colvis = [];
		var editor_cols = [];
		var editor_action = '<xsl:value-of select="editor_action"/>';
		var disablePagination = '<xsl:value-of select="disablePagination"/>';
		var select_all = '<xsl:value-of select="select_all"/>';
		var initial_search = {"search": "<xsl:value-of select="query"/>" };
		var action_def = null;
		var contextMenuItems={};
		var InitContextMenu=false

		<xsl:choose>
			<xsl:when test="//datatable/actions">
				var button_def = [
				//	{
				//		extend: 'colvis',
				//		exclude: exclude_colvis,
				//		text: function ( dt, button, config ) {
				//		return dt.i18n( 'buttons.show_hide', 'Show / hide columns' );
				//	}
				//},
				<xsl:choose>
					<xsl:when test="new_item">
						{
						text: "<xsl:value-of select="php:function('lang', 'new')"/>",
						sUrl: '<xsl:value-of select="new_item"/>',

						action: function (e, dt, node, config) {
						var sUrl = config.sUrl;
						window.open(sUrl, '_self');
						}
						},
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="select_all = '1'">
						{
						text: "<xsl:value-of select="php:function('lang', 'select all')"/>",
						action: function () {
						var api = oTable.api();
						api.rows().select();
						$(".mychecks").each(function()
						{
						$(this).prop("checked", true);
						});
						var selectedRows = api.rows( { selected: true } ).count();
						api.buttons( '.record' ).enable( selectedRows > 0 );

						}
						},
						{
						text: "<xsl:value-of select="php:function('lang', 'select none')"/>",
						action: function () {
						var api = oTable.api();
						api.rows().deselect();
						$(".mychecks").each(function()
						{
						$(this).prop("checked", false);
						});
						api.buttons( '.record' ).enable( false );
						}
						},
					</xsl:when>
				</xsl:choose>
				'excelHtml5',
				<xsl:choose>
					<xsl:when test="download">
						,{
						text: "<xsl:value-of select="php:function('lang', 'download')"/>",
						className: 'download',
						sUrl: '<xsl:value-of select="download"/>',
						action: function (e, dt, node, config) {
						var sUrl = config.sUrl;

							<![CDATA[
								var oParams = {};
								oParams.length = -1;
								oParams.columns = null;
								oParams.start = null;
								oParams.draw = null;
								var addtional_filterdata = oTable.dataTableSettings[0]['ajax']['data'];
								for (var attrname in addtional_filterdata)
								{
									oParams[attrname] = addtional_filterdata[attrname];
								}
								var iframe = document.createElement('iframe');
								iframe.style.height = "0px";
								iframe.style.width = "0px";
								iframe.src = sUrl+"&"+$.param(oParams) + "&export=1" + "&query=" + $('div.dataTables_filter input').val();

								if(confirm("This will take some time..."))
								{
									document.body.appendChild( iframe );
								}
								]]>
							}

						}
					</xsl:when>
				</xsl:choose>
				];
				var action_def = [
				<xsl:choose>
					<xsl:when test="//datatable/actions != ''">
					<xsl:for-each select="//datatable/actions">
							<xsl:choose>
								<xsl:when test="type = 'custom'">
									{
										text: "<xsl:value-of select="text"/>",
										<xsl:choose>
											<xsl:when test="className">
												className: "<xsl:value-of select="className"/>",
											</xsl:when>
											<xsl:otherwise>
												enabled: false,
												className: 'record',
											</xsl:otherwise>
										</xsl:choose>
										action: function (e, dt, node, config)
										{
										<xsl:if test="confirm_msg">
											var confirm_msg = "<xsl:value-of select="confirm_msg"/>";
											var r = confirm(confirm_msg);
											if (r != true) {
											return false;
											}
										</xsl:if>
										fnSetSelected(this);
										<xsl:value-of select="custom_code"/>
										}
									}<xsl:value-of select="phpgw:conditional(not(position() = last()), ',', '')"/>
								</xsl:when>
								<xsl:otherwise>
									{
										text: "<xsl:value-of select="text"/>",
										<xsl:choose>
											<xsl:when test="className">
												className: "<xsl:value-of select="className"/>",
											</xsl:when>
											<xsl:otherwise>
												enabled: false,
												className: 'record',
											</xsl:otherwise>
										</xsl:choose>
										action: function (e, dt, node, config) {
											var receiptmsg = [];

											fnSetSelected(this);

											var selected = fnGetSelected();
											var numSelected = 	selected.length;

											if (numSelected ==0){
												alert('None selected');
												return false;
											}

											<xsl:if test="confirm_msg">
												var confirm_msg = "<xsl:value-of select="confirm_msg"/>";
												var r = confirm(confirm_msg);
												if (r != true) {
												return false;
												}
											</xsl:if>

											var target = "<xsl:value-of select="target"/>";
											if(!target)
											{
												target = '_self';
											}

											if (numSelected &gt; 1){
												target = '_blank';
											}

											var n = 0;
											for (; n &lt; numSelected; ) {
												//				console.log(selected[n]);
													var aData = oTable.fnGetData( selected[n] ); //complete dataset from json returned from server
												//				console.log(aData);

												//delete stuff comes here
												var action = "<xsl:value-of select="action"/>";
												var my_name = "<xsl:value-of select="my_name"/>";

												<xsl:if test="parameters">
													var parameters = <xsl:value-of select="parameters"/>;
													//						console.log(parameters.parameter);
													var i = 0;
													len = parameters.parameter.length;
													for (; i &lt; len; ) {
													action += '&amp;' + parameters.parameter[i]['name'] + '=' + aData[parameters.parameter[i]['source']];
													i++;
													}
												</xsl:if>

												// look for the word "DELETE" in URL and my_name
												if(substr_count(action,'delete')>0 || substr_count(my_name,'delete')>0)
												{
													action += "&amp;confirm=yes&amp;phpgw_return_as=json";
													execute_ajax(action, function(result){
														document.getElementById("message").innerHTML += '<br/>' + result;
														oTable.fnDraw();
													});
												}
												else if (target == 'ajax')
												{
													action += "&amp;phpgw_return_as=json";
													execute_ajax(action, function(result){
														document.getElementById("message").innerHTML += '<br/>' + result;
														oTable.fnDraw();
													});
												}
												else
												{
													window.open(action,target);
												}
												n++;
											}
										}
									}<xsl:value-of select="phpgw:conditional(not(position() = last()), ',', '')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
				];
				<xsl:choose>
					<xsl:when test="group_buttons = '1'">
						var group_buttons = true;
					</xsl:when>
					<xsl:otherwise>
						var group_buttons = false;
					</xsl:otherwise>
				</xsl:choose>
	<![CDATA[

			var item_name = '';
			var contextMenuItem = {};
			for(i=0;i < action_def.length;i++)
			{
				button_def.push(action_def[i]);
				if( typeof(action_def[i]['className']) != 'undefined' && action_def[i]['className'] == 'record')
				{
					contextMenuItems[i] = {name:action_def[i]['text'], callback:action_def[i]['action']};
					InitContextMenu = true;
				}
			}

				if(button_def.length > 10)
				{
					group_buttons = true;
				}

	]]>
				if($(document).width() &lt; 1000)
				{
					group_buttons = true;
				}
				$.fn.dataTable.Buttons.swfPath = "phpgwapi/js/DataTables/extensions/Buttons/swf/flashExport.swf";


				if(group_buttons === true)
				{
					JqueryPortico.buttons = [
						{
							extend: 'collection',
							text: "<xsl:value-of select="php:function('lang', 'collection')"/>",
							collectionLayout: 'three-column',
							buttons: button_def
						}
					];
				}
				else
				{
					JqueryPortico.buttons = button_def;
				}
			</xsl:when>
			<xsl:otherwise>
				JqueryPortico.buttons = false;
			</xsl:otherwise>
		</xsl:choose>
			<![CDATA[
			for(i=0;i < JqueryPortico.columns.length;i++)
			{
				if (JqueryPortico.columns[i]['visible'] != 'undefined' && JqueryPortico.columns[i]['visible'] == false)
				{
					exclude_colvis.push(i);
				}
			}

			for(i=0;i < JqueryPortico.columns.length;i++)
			{
				if (JqueryPortico.columns[i]['editor'] === true)
				{
					editor_cols.push({sUpdateURL:editor_action + '&field_name=' + JqueryPortico.columns[i]['data']});
				}
				else
				{
					editor_cols.push(null);
				}
			}

			var order_def = [];
			for(i=0;i < JqueryPortico.columns.length;i++)
			{
				if (JqueryPortico.columns[i]['orderable'] === true && typeof(JqueryPortico.columns[i]['dir']) != 'undefined')
				{
					var dir = JqueryPortico.columns[i]['dir'] || "desc";
					order_def.push([i, dir]);
					break;
				}
			}

			if(JqueryPortico.buttons)
			{
//					var sDom_def = 'lCT<"clear">f<"top"ip>rt<"bottom"><"clear">';
					var sDom_def = 'lB<"clear">f<"top"ip>rt<"bottom"><"clear">';
					var sDom_def = 'Bfrtlip';
			}
			else
			{
				var sDom_def = '<"clear">lfrtip';
			}

		$(document).ready(function() {
			oTable = $('#datatable-container').dataTable({
				paginate:		disablePagination ? false : true,
				processing:		true,
				serverSide:		true,
				responsive:		true,
				select: select_all ? { style: 'multi' } : true,
				deferRender:	true,
				ajax:			{
					url: ajax_url,
					data: {},
					type: 'POST'
				},
				fnServerParams: function ( aoData ) {
					if(typeof(aoData.order[0]) != 'undefined')
					{
						var column = aoData.order[0].column;
						var dir = aoData.order[0].dir;
						var column_to_keep = aoData.columns[column];
						delete aoData.columns;
						aoData.columns = {};
						aoData.columns[column] = column_to_keep;
					}

					active_filters_html = [];
					var select = null;
					for (var i in filter_selects)
					{
						  select = $("#" + filter_selects[i]);
						  var select_name = select.prop("name");
						  var select_value = select.val();
						  aoData[select_name] = select_value;

						  if(select_value && select_value !=0 )
						  {
							active_filters_html.push(i);
						  }

					}

					if(active_filters_html.length > 0)
					{
						$('#active_filters').html("Aktive filter: " + active_filters_html.join(', '));
					}

				 },
				fnCreatedRow  : function( nRow, aData, iDataIndex ){
 				},
				fnRowCallback: function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
							if(typeof(aData['priority'])!= undefined && aData['priority'] > 0)
							{
								$('td', nRow).addClass('priority' + aData['priority']);
							}
                },
				fnDrawCallback: function () {
					oTable.makeEditable({
							sUpdateURL: editor_action,
							fnOnEditing: function(input){
								cell = input.parents("td");
									id = input.parents("tr").children("td:first").text();
								return true;
							},
							fnOnEdited: function(status, sOldValue, sNewCellDisplayValue, aPos0, aPos1, aPos2)
							{
								document.getElementById("message").innerHTML += '<br/>' + status;
							},
							oUpdateParameters: {
								"id": function(){ return id; }
							},
							aoColumns: editor_cols,
						    sSuccessResponse: "IGNORE",
							fnShowError: function(){ return; }
					});
					if(typeof(addFooterDatatable) == 'function')
					{
						addFooterDatatable(oTable);
					}
				},
				fnFooterCallback: function ( nRow, aaData, iStart, iEnd, aiDisplay ) {
					if(typeof(addFooterDatatable2) == 'function')
					{
						addFooterDatatable2(nRow, aaData, iStart, iEnd, aiDisplay,oTable);
					}
				},//alternative
				fnInitComplete: function (oSettings, json)
				{
					if(typeof(initCompleteDatatable) == 'function')
					{
						initCompleteDatatable(oSettings, json, oTable);
					}
				},
				lengthMenu:		JqueryPortico.i18n.lengthmenu(),
				language:		JqueryPortico.i18n.datatable(),
				columns:		JqueryPortico.columns,
				dom:			sDom_def,
				stateSave:		true,
				stateDuration: -1, //sessionstorage
				tabIndex:		1,
				"search": initial_search,
				"order": order_def,
				buttons: JqueryPortico.buttons
			});

			$('#datatable-container tbody').on( 'click', 'tr', function () {
					var api = oTable.api();
					var selectedRows = api.rows( { selected: true } ).count();
					api.buttons( '.record' ).enable( selectedRows > 0 );
					var row = $(this);
					var checkbox = row.find('input[type="checkbox"]');

					if(checkbox && checkbox.hasClass('mychecks'))
					{
						if($(this).hasClass('selected'))
						{
							checkbox.prop("checked", true);
						}
						else
						{
							checkbox.prop("checked", false);
						}
					}
			   } );

			if(InitContextMenu === true)
			{
				$('#datatable-container').contextMenu({
					  selector: 'tr',
					   items: contextMenuItems,
				});
			}

			if(number_of_toolbar_items < 4)
			{
				$('#header1').prop("checked", true);
			}
		});
	]]>

		/**
		* Add left click action..
		*/
		<xsl:if test="//left_click_action != ''">
			$("#datatable-container").on("click", "tbody tr", function() {
			var iPos = oTable.fnGetPosition( this );
			var aData = oTable.fnGetData( iPos ); //complete dataset from json returned from server
			try {
			<xsl:value-of select="//left_click_action"/>
			}
			catch(err) {
			document.getElementById("message").innerHTML = err.message;
			}
			});
		</xsl:if>

		/**
		* Add dbl click action..
		*/
		<xsl:if test="dbl_click_action != ''">
			$("#datatable-container").on("dblclick", "tr", function() {
			var iPos = oTable.fnGetPosition( this );
			var aData = oTable.fnGetData( iPos ); //complete dataset from json returned from server
			try {
			<xsl:value-of select="dbl_click_action"/>(aData);
			}
			catch(err) {
			document.getElementById("message").innerHTML = err.message;
			}
			});
		</xsl:if>

		<xsl:for-each select="//form/toolbar/item">
			<xsl:if test="type = 'filter'">
				$('select#<xsl:value-of select="name"/>').change( function()
				{
					<xsl:value-of select="extra"/>
					filterData('<xsl:value-of select="name"/>', $(this).val());
				});
			</xsl:if>
			<xsl:if test="type = 'date-picker'">
				var previous_<xsl:value-of select="id"/>;
				$("#filter_<xsl:value-of select="id"/>").on('keyup change', function ()
				{
					if ( $.trim($(this).val()) != $.trim(previous_<xsl:value-of select="id"/>) )
					{
						filterData('<xsl:value-of select="id"/>', $(this).val());
						previous_<xsl:value-of select="id"/> = $(this).val();
					}
				});
			</xsl:if>
			<xsl:if test="type = 'autocomplete'">
				$(document).ready(function() {
					$('input.ui-autocomplete-input#filter_<xsl:value-of select="name"/>_name').on('autocompleteselect', function(event, ui){
						filterData('filter_<xsl:value-of select="name"/>_id', ui.item.value);
					});
					$('input.ui-autocomplete-input#filter_<xsl:value-of select="name"/>_name').on('keyup', function(){
						if ($(this).val() == '')
						{
							$('#filter_<xsl:value-of select="name"/>_id').val('');
							filterData('filter_<xsl:value-of select="name"/>_id', $(this).val());
						}
					});
				});
			</xsl:if>
		</xsl:for-each>
	<![CDATA[
			function fnGetSelected( )
			{
				var aReturn = new Array();
				 var aTrs = oTable.fnGetNodes();
				 for ( var i=0 ; i < aTrs.length ; i++ )
				 {
					 if ( $(aTrs[i]).hasClass('selected') )
					 {
						 aReturn.push( i );
					 }
				 }
				 return aReturn;
			}

			function fnSetSelected( row )
			{
				if(typeof(row[0]) == 'undefined')
				{
					return false;
				}

				var sectionRowIndex = row[0].sectionRowIndex;
				if(typeof(sectionRowIndex) != 'undefined')
				{
					var table = oTable.DataTable();
					var selected = table.row( sectionRowIndex ).select();
				}
			}

			function execute_ajax(requestUrl, callback, data,type, dataType)
			{
				type = typeof type !== 'undefined' ? type : 'POST';
				dataType = typeof dataType !== 'undefined' ? dataType : 'html';
				data = typeof data !== 'undefined' ? data : {};

				$.ajax({
					type: type,
					dataType: dataType,
					data: data,
					url: requestUrl,
					success: function(result) {
						callback(result);
					}
				});
			}

			function substr_count( haystack, needle, offset, length )
			{
				var pos = 0, cnt = 0;

				haystack += '';
				needle += '';
				if(isNaN(offset)) offset = 0;
				if(isNaN(length)) length = 0;
				offset--;

				while( (offset = haystack.indexOf(needle, offset+1)) != -1 )
				{
					if(length > 0 && (offset+needle.length) > length)
					{
						return false;
					}
					else
					{
						cnt++;
					}
				}
				return cnt;
			}
		});

		function searchData(query)
		{
			var api = oTable.api();
			api.search( query ).draw();
		}

		function filterData(param, value)
		{
			oTable.dataTableSettings[0]['ajax']['data'][param] = value;
			oTable.fnDraw();
		}

		function clearFilterParam(param)
		{
			oTable.dataTableSettings[0]['ajax']['data'][param] = '';
		}

		function reloadData()
		{
			var api = oTable.api();
			api.ajax.reload();
		}
	]]>
	</script>

	<script>
		<xsl:choose>
			<xsl:when test="//js_lang != ''">
				var lang = <xsl:value-of select="//js_lang"/>;
			</xsl:when>
		</xsl:choose>
	</script>
</xsl:template>
