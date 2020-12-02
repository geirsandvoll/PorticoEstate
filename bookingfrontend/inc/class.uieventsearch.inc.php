<?php
phpgw::import_class("booking.uicommon");
phpgw::import_class('bookingfrontend.bosearch');
phpgw::import_class('booking.bobooking');
phpgw::import_class('bookingfrontend.bouser');


class bookingfrontend_uieventsearch extends booking_uicommon
{

	public $public_functions = array
	(
		'index' => true,
		'show'  => true,
		'upcomingEvents' => true,
		'getOrgsIfLoggedIn' => true
	);

	protected $module;
	protected $bosearch;
	protected $bo_booking;

	public function __construct()
	{
		parent::__construct();
		$this->module= "bookingfrontend";
		$this->bosearch = new bookingfrontend_bosearch();
		$this->bo_booking = new booking_bobooking();
	}

	public function show()
	{
		phpgwapi_jquery::load_widget('autocomplete');

		$event_search['dickens'] = "test";
		$config = CreateObject('phpgwapi.config', 'booking');
		$config->read();
		phpgwapi_jquery::load_widget("core");

		self::add_javascript('bookingfrontend', 'aalesund', 'event_search.js', 'text/javascript', true);
		self::render_template_xsl('event_search', array('event_search' => $event_search));

	}

	public function getOrgsIfLoggedIn()
	{
		$bouser = new bookingfrontend_bouser();
		$orgs = null;
		if ($bouser->is_logged_in()) {
			$orgs = (array)phpgwapi_cache::session_get($bouser->get_module(), $bouser::ORGARRAY_SESSION_KEY);
		}

		$orgs_map = array();
		foreach ($orgs as $org)
		{
			$orgs_map[] = $org['orgnumber'];
		}
		return $orgs_map;
	}


	/***
	 * Metode for å hente events til søkesiden
	 */
	public function upcomingEvents()
	{
		$orgName = phpgw::get_var('orgName', 'string', 'REQUEST', null);
		$fromDate = phpgw::get_var('fromDate', 'string', 'REQUEST', null);
		$toDate = phpgw::get_var('toDate', 'string', 'REQUEST', null);
		$buildingId = phpgw::get_var('buildingID', 'string', 'REQUEST', null);
		$facilityTypeID = phpgw::get_var('facilityTypeID', 'string', 'REQUEST', null);
		$loggedInOrgs = phpgw::get_var('loggedInOrgs', 'string', 'REQUEST', null);

		$result_string = "'" . str_replace(",", "','", $loggedInOrgs) . "'";

		$events = $this->bosearch->soevent->get_events_from_date($fromDate, $toDate, $orgName, $buildingId, $facilityTypeID, $result_string);
		return $events;
	}

	public function index()
	{
		if (phpgw::get_var('phpgw_return_as') == 'json')
		{
			return $this->query();
		}

		phpgw::no_access();
	}

	public function query()
	{
		// TODO: Implement query() method.
	}
}