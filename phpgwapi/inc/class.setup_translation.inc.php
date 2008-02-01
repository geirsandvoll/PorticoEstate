<?php
	/**
	* Setup translation - Handles multi-language support using flat files
	* @author Miles Lott <milosch@phpgroupware.org>
	* @author Dan Kuykendall <seek3r@phpgroupware.org>
	* @copyright Portions Copyright (C) 2001-2004 Free Software Foundation, Inc. http://www.fsf.org/
	* @license http://www.fsf.org/licenses/lgpl.html GNU Lesser General Public License
	* @package phpgwapi
	* @subpackage application
	* @version $Id$
	*/

	phpgw::import_class('phpgwapi.translation');

	/**
	* Setup translation - Handles multi-language support using flat files
	* 
	* @package phpgwapi
	* @subpackage application
	*/
	class phpgwapi_setup_translation
	{
		var $langarray;

		/**
		 * constructor for the class, loads all phrases into langarray
		*
		 * @param $lang	user lang variable (defaults to en)
		 */
		function __construct()
		{
			$ConfigLang = phpgw::get_var('ConfigLang');

			if($ConfigLang)
			{
				$this->userlang = $ConfigLang;
			}

			$fn = "./lang/phpgw_{$lang}.lang";
			if (!file_exists($fn))
			{
				$fn = './lang/phpgw_en.lang';
			}

			if (file_exists($fn))
			{
				$fp = fopen($fn,'r');
				while ($data = fgets($fp,8000))
				{
					list($message_id,$app_name,$null,$content) = explode("\t",$data);
					if ($app_name == 'setup' || $app_name == 'common' || $app_name == 'all')
					{
						$this->langarray[] = array(
							'message_id' => $message_id,
							'content'    => trim($content)
						);
					}
				}
				fclose($fp);
			}
		}
		
		/**
		 * Translate phrase to user selected lang
		*
		 * @param $key  phrase to translate
		 * @param $vars vars sent to lang function, passed to us
		 */
		function translate($key, $vars=False) 
		{
			if (!$vars)
			{
				$vars = array();
			}

			$ret = $key;

			@reset($this->langarray);
			while(list($null,$data) = @each($this->langarray))
			{
				$lang[strtolower($data['message_id'])] = $data['content'];
			}

			if (isset($lang[strtolower ($key)]) && $lang[strtolower ($key)])
			{
				$ret = $lang[strtolower ($key)];
			}
			else
			{
				$ret = $key.'*';
			}
			$ndx = 1;
			while( list($key,$val) = each( $vars ) )
			{
				$ret = preg_replace( "/%$ndx/", $val, $ret );
				++$ndx;
			}
			return $ret;
		}

		/* Following functions are called for app (un)install */

		/**
		 * return array of installed languages, e.g. array('de','en')
		*
		 */
		function get_langs($DEBUG=False)
		{
			if($DEBUG)
			{
				echo '<br>get_langs(): checking db...' . "\n";
			}
			$GLOBALS['phpgw_setup']->db->query("SELECT DISTINCT(lang) FROM phpgw_lang",__LINE__,__FILE__);
			$langs = array();

			while($GLOBALS['phpgw_setup']->db->next_record())
			{
				if($DEBUG)
				{
					echo '<br>get_langs(): found ' . $GLOBALS['phpgw_setup']->db->f(0);
				}
				$langs[] = $GLOBALS['phpgw_setup']->db->f(0);
			}
			return $langs;
		}

		/**
		 * delete all lang entries for an application, return True if langs were found
		*
		 * @param $appname app_name whose translations you want to delete
		 */
		function drop_langs($appname,$DEBUG=False)
		{
			if($DEBUG)
			{
				echo '<br>drop_langs(): Working on: ' . $appname;
			}
			$GLOBALS['phpgw_setup']->db->query("SELECT COUNT(message_id) FROM phpgw_lang WHERE app_name='$appname'",__LINE__,__FILE__);
			$GLOBALS['phpgw_setup']->db->next_record();
			if($GLOBALS['phpgw_setup']->db->f(0))
			{
				if(function_exists('sem_get'))
				{
					if ( !isset($GLOBALS['phpgw']->shm) || !is_object($GLOBALS['phpgw']->shm) )
					{
						$GLOBALS['phpgw']->shm = CreateObject('phpgwapi.shm');
					}

					$GLOBALS['phpgw_setup']->db->query("SELECT lang FROM phpgw_lang WHERE app_name='$appname'",__LINE__,__FILE__);
					while ($GLOBALS['phpgw_setup']->db->next_record())
					{
						$GLOBALS['phpgw']->shm->delete_key('lang_' . $GLOBALS['phpgw_setup']->db->f('lang'));
					}
				}

				$GLOBALS['phpgw_setup']->db->query("DELETE FROM phpgw_lang WHERE app_name='$appname'",__LINE__,__FILE__);

				return True;
			}
			return False;
		}

		/**
		 * process an application's lang files, calling get_langs() to see what langs the admin installed already
		*
		 * @param $appname app_name of application to process
		 */
		function add_langs($appname,$DEBUG=False,$force_en=False)
		{
			$langs = $this->get_langs($DEBUG);
			if($force_en && !@in_array('en',$langs))
			{
				$langs[] = 'en';
			}

			if($DEBUG)
			{
				echo '<br>add_langs(): chose these langs: ';
				_debug_array($langs);
			}

			while (list($null,$lang) = each($langs))
			{
				if($DEBUG)
				{
					echo '<br>add_langs(): Working on: ' . $lang . ' for ' . $appname;
				}
				$appfile = PHPGW_SERVER_ROOT . "/{$appname}/setup/phpgw_" . strtolower($lang) . '.lang';
				if(file_exists($appfile))
				{
					if($DEBUG)
					{
						echo '<br>add_langs(): Including: ' . $appfile;
					}
					$raw_file = file($appfile);

					foreach ( $raw_file as $line ) 
					{
						list($message_id,$app_name,$GLOBALS['phpgw_setup']->db_lang,$content) = explode("\t",$line);
						if ( !strlen($content) )
						{
							echo "ERROR: Invalid translation entry: '$line'\n in /path/to/phpgroupware/$appname/setup/phpgw_$lang.lang<br>\n";
						}

						$message_id = $GLOBALS['phpgw_setup']->db->db_addslashes(chop(substr($message_id,0,MAX_MESSAGE_ID_LENGTH)));
						/* echo '<br>APPNAME:' . $app_name . ' PHRASE:' . $message_id; */
						$app_name   = $GLOBALS['phpgw_setup']->db->db_addslashes(chop($app_name));
						$GLOBALS['phpgw_setup']->db_lang    = $GLOBALS['phpgw_setup']->db->db_addslashes(chop($GLOBALS['phpgw_setup']->db_lang));
						$content    = $GLOBALS['phpgw_setup']->db->db_addslashes(chop($content));

						$GLOBALS['phpgw_setup']->db->query("SELECT COUNT(*) FROM phpgw_lang WHERE message_id='$message_id' and lang='"
							. $GLOBALS['phpgw_setup']->db_lang . "'",__LINE__,__FILE__);
						$GLOBALS['phpgw_setup']->db->next_record();

						if ($GLOBALS['phpgw_setup']->db->f(0) == 0)
						{
							if($message_id && $content)
							{
								if($DEBUG)
								{
									echo "<br>add_langs(): adding - INSERT INTO phpgw_lang VALUES ('$message_id','$app_name','"
										. $GLOBALS['phpgw_setup']->db_lang . "','$content')";
								}
								$GLOBALS['phpgw_setup']->db->query("INSERT INTO phpgw_lang VALUES ('$message_id','$app_name','"
									. $GLOBALS['phpgw_setup']->db_lang . "','$content')",__LINE__,__FILE__);
							}
						}
					}
				}
			}
		}
	}
