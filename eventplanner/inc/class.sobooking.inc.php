<?php
	/**
	 * phpGroupWare - property: a part of a Facilities Management System.
	 *
	 * @author Sigurd Nes <sigurdne@online.no>
	 * @copyright Copyright (C) 2016 Free Software Foundation, Inc. http://www.fsf.org/
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
	 * @internal Development of this application was funded by http://www.bergen.kommune.no/
	 * @package eventplanner
	 * @subpackage booking
	 * @version $Id: $
	 */
	phpgw::import_class('phpgwapi.socommon');

	class eventplanner_sobooking extends phpgwapi_socommon
	{

		protected static $so;

		public function __construct()
		{
			parent::__construct('eventplanner_booking', eventplanner_booking::get_fields());
		}

		/**
		 * Implementing classes must return an instance of itself.
		 *
		 * @return the class instance.
		 */
		public static function get_instance()
		{
			if (self::$so == null)
			{
				self::$so = CreateObject('eventplanner.sobooking');
			}
			return self::$so;
		}


		protected function populate( array $data )
		{
			$object = new eventplanner_booking();
			foreach ($this->fields as $field => $field_info)
			{
				$object->set_field($field, $data[$field]);
			}

			return $object;
		}

		protected function update( $object )
		{
			$this->db->transaction_begin();
			$this->update_history($object, $this->fields);

			parent::update($object);

			return	$this->db->transaction_commit();
		}

		protected function update_history( $object, $fields )
		{
	//		$status_text = eventplanner_booking::get_status_list();
			$dateformat = $GLOBALS['phpgw_info']['user']['preferences']['common']['dateformat'];
			$lang_active = lang('active');
			$lang_inactive = lang('inactive');

			$original = $this->read_single($object->get_id());//returned as array()
			foreach ($fields as $field => $params)
			{
				$new_value = $object->$field;
				$old_value = $original[$field];
				if (!empty($params['history']) && $new_value && $old_value && ($new_value != $old_value))
				{
					$label = !empty($params['label']) ? lang($params['label']) : $field;
					switch ($field)
					{
						case 'status':
							$old_value = $status_text[$old_value];
							$new_value = $status_text[$new_value];
							break;
						case 'active':
							$old_value = $old_value ? $lang_active : $lang_inactive;
							$new_value = $new_value ? $lang_active : $lang_inactive;
							break;
						case 'from_':
						case 'to_':
							if(($old_value + phpgwapi_datetime::user_timezone()) == $new_value)
							{
								continue;
							}

							$old_value = $GLOBALS['phpgw']->common->show_date($old_value);
							$new_value = $GLOBALS['phpgw']->common->show_date($new_value);
							break;
						default:
							break;
					}
					$value_set = array
					(
						'booking_id'	=> $object->get_id(),
						'time'		=> time(),
						'author'	=> $GLOBALS['phpgw_info']['user']['fullname'],
						'comment'	=> $label . ':: ' . lang('old value') . ': ' . $this->db->db_addslashes($old_value) . ', ' .lang('new value') . ': ' . $this->db->db_addslashes($new_value),
						'type'	=> 'history',
					);

					$this->db->query( 'INSERT INTO eventplanner_booking_comment (' .  implode( ',', array_keys( $value_set ) )   . ') VALUES ('
					. $this->db->validate_insert( array_values( $value_set ) ) . ')',__LINE__,__FILE__);
				}

			}
		}

		public function update_active_status($ids, $action )
		{
			if(!$ids || !is_array($ids))
			{
				return;
			}

			switch ($action)
			{
				case 'disable':
					$sql = "UPDATE eventplanner_booking SET active = 0";
					$where = 'WHERE';

					break;
				case 'enable':
					$sql = "UPDATE eventplanner_booking SET active = 1";
					$where = 'WHERE';
					break;

				case 'delete':
					$sql = "DELETE FROM eventplanner_booking WHERE customer_id IS NULL";
					$where = 'AND';
					break;

				case 'disconnect':
					$sql = "UPDATE eventplanner_booking SET"
					. " customer_id = NULL,"
					. " customer_contact_name = NULL,"
					. " customer_contact_email = NULL,"
					. " customer_contact_phone = NULL,"
					. " location = NULL";
					$where = 'WHERE';
					break;

				default:
					throw new Exception("action {$action} not supported");
					break;
			}

			$sql .= " {$where} id IN(". implode(',', $ids) . ')';
			$this->db->transaction_begin();
			
			$this->db->query($sql,__LINE__,__FILE__);


			return	$this->db->transaction_commit();
		}
	}