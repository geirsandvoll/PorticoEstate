<xsl:template match="data" xmlns:php="http://php.net/xsl">
	<style>
		/* Chrome, Safari, Edge, Opera */
		input::-webkit-outer-spin-button,
		input::-webkit-inner-spin-button {
		-webkit-appearance: none;
		margin: 0;
		}

		/* Firefox */
		input[type=number] {
		-moz-appearance: textfield;
		}
	</style>

	<div id="group-edit-page-content" class="margin-top-content">
		<div class="container wrapper">

			<xsl:if test="name !=''">
				<h1>
					<xsl:value-of select="name" />
				</h1>
			</xsl:if>

			<xsl:if test="reservation/group/name">
				<h3>
					<xsl:value-of select="reservation/group/organization_name"/>
				</h3>
				<div class="mb-3">
					<span class="font-weight-bold text-uppercase">
						<xsl:value-of select="php:function('lang', 'Group (2018)')"/>:
					</span>
					<xsl:value-of select="reservation/group/name"/>
				</div>
			</xsl:if>

			<span class="d-block">
				<xsl:value-of select="when"/>
			</span>
			<div>
				<span class="font-weight-bold text-uppercase">
					<xsl:value-of select="php:function('lang', 'Place')"/>:
				</span>
				<xsl:value-of select="reservation/building_name"/>
				(<xsl:value-of select="reservation/resource_info"/>)
			</div>
			<xsl:if test="participant_limit > 0">
				<span class="d-block">
					<xsl:value-of select="php:function('lang', 'participant limit')" />:
					<xsl:value-of select="participant_limit" />
				</span>
			</xsl:if>
			<span class="d-block">
				<xsl:value-of select="php:function('lang', 'number of participants')" />:
				<xsl:value-of select="number_of_participants" />
			</span>
			<span class="d-block">
				<xsl:value-of select="participanttext" disable-output-escaping="yes"/>
			</span>
			<xsl:choose>
				<xsl:when test="enable_register_form = 1">
					<form action="{data/form_action}" method="POST" id="form" name="form" class="col-lg-8">
						<div class="row">
							<div class="col-12">
								<xsl:call-template name="msgbox"/>
							</div>

							<div class="col-12">
								<div class="form-group">
									<label for="phone" class="text-uppercase">
										<xsl:value-of select="php:function('lang', 'phone')" />
									</label>
									<input id="phone" name="phone" class="form-control" type="tel" autocomplete="off" value="{phone}" oninput="check(this)">
										<xsl:attribute name="required">
											<xsl:text>required</xsl:text>
										</xsl:attribute>
<!--										<xsl:attribute name="placeholder">
											<xsl:value-of select="php:function('lang', 'Minimum 8 digits')" />
										</xsl:attribute>-->
									</input>
								</div>
							</div>
							<div class="col-12">
								<div class="form-group">
									<label for="quantity" class="text-uppercase">
										<xsl:value-of select="php:function('lang', 'quantity')" />
									</label>
									<input id="quantity" name="quantity" class="form-control" type="number" min="1" value="{quantity}">
										<xsl:attribute name="required">
											<xsl:text>required</xsl:text>
										</xsl:attribute>
									</input>
								</div>
							</div>

							<!--					<div class="col-12">
								<div class="form-group">
									<label for="email" class="text-uppercase">
										<xsl:value-of select="php:function('lang', 'email')" />
									</label>
									<input id="email" name="email" type="email" class="form-control" value="{email}">
									</input>
								</div>
							</div>-->

							<input id="register_type" name="register_type" type="hidden"/>

							<xsl:if test="enable_register_pre = 1">
								<div class="col-12 mt-3 mb-2">
									<button type="submit" value="register_pre" class="btn btn-primary btn-lg col-12 mr-4" onclick="validate_submit('register_pre');">
										<xsl:value-of select="php:function('lang', 'Pre-register')" />
									</button>
								</div>
							</xsl:if>

							<xsl:if test="enable_register_in = 1">
								<div class="col-12 mt-3 mb-2">
									<button type="submit" value="register_in" class="btn btn-primary btn-lg col-12 mr-4" onclick="validate_submit('register_in');">
										<xsl:value-of select="lang_register_in" />
									</button>
								</div>
							</xsl:if>
							<xsl:if test="enable_register_out = 1">
								<div class="col-12 mt-3 mb-2">
									<button type="submit" value="register_out" class="btn btn-primary btn-lg col-12 mr-4" onclick="validate_submit('register_out');">
										<xsl:value-of select="php:function('lang', 'Register out')" />
									</button>
								</div>
							</xsl:if>
						</div>
					</form>
				</xsl:when>
				<xsl:otherwise>
					<span class="d-block mt-3">
						<xsl:value-of select="php:function('lang', 'registration has ended')" />
					</span>
				</xsl:otherwise>
			</xsl:choose>

		</div>
	</div>
	<script>



	</script>
</xsl:template>