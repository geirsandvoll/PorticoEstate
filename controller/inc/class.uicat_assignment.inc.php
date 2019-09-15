<?php
	/**
	 * phpGroupWare - property: a Facilities Management System.
	 *
	 * @author Sigurd Nes <sigurdne@online.no>
	 * @copyright Copyright (C) 2018 Free Software Foundation, Inc. http://www.fsf.org/
	 * This file is part of phpGroupWare.
	 *
	 * phpGroupWare is free software; you can redistribute it and/or modify
	 * it under the terms of the GNU General Public License as published by
	 * the Free Software Foundation; either version 2 of the License, or
	 * (at your option) any later version.
	 *
	 * phpGroupWare is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 * GNU General Public License for more details.
	 *
	 * You should have received a copy of the GNU General Public License
	 * along with phpGroupWare; if not, write to the Free Software
	 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
	 *
	 * @license http://www.gnu.org/licenses/gpl.html GNU General Public License
	 * @internal Development of this application was funded by http://www.bergen.kommune.no/bbb_/ekstern/
	 * @package property
	 * @subpackage helpdesk
	 * @version $Id$
	 */
	/**
	 * Description
	 * @package property
	 */
	phpgw::import_class('phpgwapi.uicommon');

	class controller_uicat_assignment extends phpgwapi_uicommon
	{

		var $public_functions = array
		(
			'edit'			=> true,
		);

		private $acl_location, $acl_read, $acl_add, $acl_edit, $acl_delete,
			$so, $cats;

		public function __construct()
		{
			parent::__construct();

			self::set_active_menu("admin::helpdesk::cat_assignment");
			
			$GLOBALS['phpgw_info']['flags']['app_header'] .= '::' . lang('category assignment');

			$this->cats		= CreateObject('phpgwapi.categories', -1, 'property', '.ticket');
			$this->cats->supress_info = true;
			$this->acl = & $GLOBALS['phpgw']->acl;
			$this->acl_location = '.control';
			$this->acl_read = $this->acl->check($this->acl_location, PHPGW_ACL_READ, 'controller');
			$this->acl_add = $this->acl->check($this->acl_location, PHPGW_ACL_ADD, 'controller');
			$this->acl_edit = $this->acl->check($this->acl_location, PHPGW_ACL_EDIT, 'controller');
			$this->acl_delete = $this->acl->check($this->acl_location, PHPGW_ACL_DELETE, 'controller');
			$this->so			= CreateObject('controller.socat_assignment');

		}

		public function add()
		{
			if(!$this->acl_add)
			{
				phpgw::no_access();
			}

			$this->edit();
		}

		public function view()
		{
			if(!$this->acl_read)
			{
				phpgw::no_access();
			}

			/**
			 * Do not allow save / send here
			 */
			if(phpgw::get_var('save', 'bool') || phpgw::get_var('send', 'bool') || phpgw::get_var('init_preview', 'bool'))
			{
				phpgw::no_access();
			}
			$this->edit(array(), 'view');
		}


		public function edit( $values = array(), $mode = 'edit' , $error = false)
		{

			if(!$this->acl_add || !$this->acl_edit)
			{
				phpgw::no_access();
			}


			if(!$error && (phpgw::get_var('save', 'bool') || phpgw::get_var('send', 'bool')))
			{
				$this->save();
			}

			$controls = CreateObject('controller.socontrol')->get(0, 0, 'controller_control.title', true, '', '', array());
//			_debug_array($controls);

			$categories = $this->cats->return_sorted_array(0, false);
//			_debug_array($categories);
			$cat_assignment = $this->so->read();
//			_debug_array($cat_assignment);die();

			$cat_header[] = array
			(
				'lang_name'				=> lang('name'),
				'lang_status'			=> lang('status'),
				'lang_edit'				=> lang('edit'),
			);

			$content = array();
			foreach ($controls as $control)
			{
				$control_name	= $GLOBALS['phpgw']->strip_html($control->get_title());

				$selected_cat = !empty($cat_assignment[$control->get_id()]['cat_id']) ? $cat_assignment[$control->get_id()]['cat_id'] : 0;

				$_cat_list = $categories;

				foreach ($_cat_list as &$cat)
				{
					$level		= $cat['level'];
					$cat_name	= $GLOBALS['phpgw']->strip_html($cat['name']);

					if ($level > 0)
					{
						$space = ' . ';
						$spaceset = str_repeat($space,$level);
						$cat_name = $spaceset . $cat_name;
					}

					$cat['name'] = $cat_name;

					$cat['selected'] = $selected_cat == $cat['id'] ? 1 : 0;
				}

				$content[] = array
				(
					'control_id'				=> $control->get_id(),
					'name'						=> $control_name,
					'cat_list'					=> array('options' => $_cat_list),
				);
			}

			$link_data['menuaction'] = 'controller.uicat_assignment.edit';

			$cat_add[] = array
			(
				'lang_add'				=> lang('add'),
				'lang_add_statustext'	=> lang('add a category'),
				'action_url'			=> $GLOBALS['phpgw']->link('/index.php',$link_data),
				'lang_done'				=> lang('done'),
				'lang_done_statustext'	=> lang('return to admin mainscreen')
			);
			$data = array
			(
				'form_action'	=> self::link(array('menuaction' => "{$this->currentapp}.uicat_assignment.edit")),
				'edit_action' => self::link(array('menuaction' => "{$this->currentapp}.uicat_assignment.edit")),
				'cancel_url' => self::link(array('menuaction' => "{$this->currentapp}.uitts.index")),
				'cat_header'	=> $cat_header,
				'cat_data'		=> $content,
				'cat_add'		=> $cat_add
			);

			$GLOBALS['phpgw_info']['flags']['app_header'] .= '::' . lang($mode);

			self::render_template_xsl(array('cat_assignment'), array('edit' => $data));

		}


		public function save()
		{
			$values = phpgw::get_var('values');
			
			try
			{
				$receipt = $this->so->save($values);
			}
			catch (Exception $e)
			{
				if ($e)
				{
					phpgwapi_cache::message_set($e->getMessage(), 'error');
					$this->edit($values, 'edit', $error = true);
					return;
				}
			}

			$this->receipt['message'][] = array('msg' => lang('category assignment has been saved'));

			self::message_set($this->receipt);
			self::redirect(array('menuaction' => "{$this->currentapp}.uicat_assignment.edit"));
		}
	}