<?php
	/**************************************************************************\
	* phpGroupWare - Developer Tools                                           *
	* http://www.phpgroupware.org                                              *
	* --------------------------------------------                             *
	*  This program is free software; you can redistribute it and/or modify it *
	*  under the terms of the GNU General Public License as published by the   *
	*  Free Software Foundation; either version 2 of the License, or (at your  *
	*  option) any later version.                                              *
	\**************************************************************************/

	/* $Id: class.sochangelogs.inc.php,v 1.3 2001/11/18 08:01:50 milosch Exp $ */

	class sochangelogs
	{
		var $db;

		function sochangelogs()
		{
			$this->db = $GLOBALS['phpgw']->db;
		}

		function list_changelogs()
		{
		
		}

		function add($fields)
		{
			$this->db->query("insert into phpgw_devtools_changelogs (changelog_cat,changelog_version,"
					. "changelog_content,changelog_timestamp) values ('" . $fields['project'] . "','"
					. $fields['version'] . "','" . $fields['change'] . "','" . time() . "')",__LINE__,__FILE__);
		}

		function search()
		{

		}

		function create_sgml()
		{

		}

	}
