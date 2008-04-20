<?php
require_once(GALAXIA_LIBRARY.'/'.'src'.'/'.'common'.'/'.'Base.php');
//!! ProcessMonitor
//! ProcessMonitor class
/*!
This class provides methods for use in typical monitoring scripts
A first part are methods for cleaning up instances and workitems associated with a process
A second part are methods to obtains information about the actual state or histroy of the process
*/
class ProcessMonitor extends Base
{

  // Constructor receiving a database abstraction object.
  function ProcessMonitor(&$db)
  {
    $this->child_name = 'ProcessMonitor';
    parent::Base($db);
    // check the the actual user can really do this
    if ( !(galaxia_user_can_monitor()))
    {
      unset($this);
      galaxia_show_error('forbidden access to ProcessMonitor object');
    }
  }


  //! return statistics about all processes handled by the engine.
  /*!
  * result is an array of this form:
  * array(
  *   [active_processes] => number
  *   [processes] => number (total number of processes)
  *   [running_processes] => number
  *   [active_instances] => number
  *   [completed_instances] => number
  *   [exception_instances] => number
  *   [aborted_instances] => number
  * )
  */
  function monitor_stats() {
    $res = Array();
    $res['active_processes'] = $this->getOne("select count(*) from `".GALAXIA_TABLE_PREFIX."processes` where `wf_is_active`=?",array('y'));
    $res['processes'] = $this->getOne("select count(*) from `".GALAXIA_TABLE_PREFIX."processes`");
    $result = $this->query("select distinct(`wf_p_id`) from `".GALAXIA_TABLE_PREFIX."instances` where `wf_status`=?",array('active'));
    $res['running_processes'] = $result->numRows();
    // get the number of instances per status
    $query = "select wf_status, count(*) as num_instances from ".GALAXIA_TABLE_PREFIX."instances group by wf_status";
    $result = $this->query($query);
    $status = array();
    while($info = $result->fetchRow()) {
      $status[$info['wf_status']] = $info['num_instances'];
    }
    $res['active_instances'] = isset($status['active']) ? $status['active'] : 0;
    $res['completed_instances'] = isset($status['completed']) ? $status['completed'] : 0;
    $res['exception_instances'] = isset($status['exception']) ? $status['exception'] : 0;
    $res['aborted_instances'] = isset($status['aborted']) ? $status['aborted'] : 0;
    return $res;
  }

  //! no need for an update function here. function update_instance_status Deprecated @deprecated
  /*
  function update_instance_status($iid,$status) {
    $query = "update `".GALAXIA_TABLE_PREFIX."instances` set `wf_status`=? where `wf_instance_id`=?";
    $this->query($query,array($status,$iid));
  }
  */

  //! no need for an update function here. function update_instance_activity_status Deprecated @deprecated
  /*
  function update_instance_activity_status($iid,$activityId,$status) {
    $query = "update `".GALAXIA_TABLE_PREFIX."instance_activities` set `wf_status`=? where `wf_instance_id`=? and `wf_activity_id`=?";
    $this->query($query,array($status,$iid,$activityId));
  }
  */

  //! definitively remove an instance from the database. DANGEROUS
  /*!
  * The instance will be removed but all workitems (history) will be removed as well and all actual activities
  * and properties of this instance as well.
  * @param iid is the instance id
  * @return true if everything was ok, false in the other case (and nothing was done)
  */
  function remove_instance($iid)
  {
    // start a transaction
    $this->db->StartTrans();
    $query = "delete from `".GALAXIA_TABLE_PREFIX."workitems` where `wf_instance_id`=?";
    $this->query($query,array($iid));
    $query = "delete from `".GALAXIA_TABLE_PREFIX."instance_activities` where `wf_instance_id`=?";
    $this->query($query,array($iid));
    $query = "delete from `".GALAXIA_TABLE_PREFIX."instances` where `wf_instance_id`=?";
    $this->query($query,array($iid));
    // perform commit (return true) or Rollback (return false)
    return $this->db->CompleteTrans();

  }

  //! definitively remove __all__ aborted instance from the database. DANGEROUS
  /*!
  * All aborted instances will be removed but all workitems (history) associated with theses instances as well
  * you can limit this behaviour to one process by specifying a process id.
  * @param $process_id is a process id you can give to limit this function to only one process.
  * Aborted instances from other processes wont be removed
  * @return true if everything was ok, false in the other case (and nothing was done)
  */
  function remove_aborted($pId=0)
  {
    // check the the actual user can really do this
    if ( !((galaxia_user_can_clean_instances()) || (galaxia_user_can_clean_aborted_instances())) )
    {
      $this->error[] = tra('user is not authorized to delete aborted instances');
      return false;
    }
    if (!(pId))
    {
      $whereand = '';
      $bindvars = array('aborted');
    }
    else
    {
      $whereand = 'and wf_p_id = ?';
      $bindvars = array('aborted', $pId);
    }
    $query="select `wf_instance_id` from `".GALAXIA_TABLE_PREFIX."instances` where `wf_status`=?".$whereand;
    // start a transaction
    $this->db->StartTrans();
    $result = $this->query($query,$bindvars);
    while($res = $result->fetchRow())
    {
      $iid = $res['wf_instance_id'];
      $query = "delete from `".GALAXIA_TABLE_PREFIX."instance_activities` where `wf_instance_id`=?";
      $this->query($query,array($iid));
      $query = "delete from `".GALAXIA_TABLE_PREFIX."workitems` where `wf_instance_id`=?";
      $this->query($query,array($iid));
    }
    $query = "delete from `".GALAXIA_TABLE_PREFIX."instances` where `wf_status`=?".$whereand;
    $this->query($query,$bindvars);
    // perform commit (return true) or Rollback (return false)
    return $this->db->CompleteTrans();
  }

  //! definitively remove __all__ instance/history of a process from the database. VERY DANGEROUS
  /*!
  * For a given process, all instances, in all states, completed, aborted, exception, running...  will be removed
  * and all workitems (history) or activities actually running  associated with theses instances as well.
  * @param process_id is the id of the process for which we will remove theses things
  * @return true if everything was ok, false in the other case (and nothing was done)
  */
  function remove_all($pId) {
    // check the the actual user can really do this
    if ( !(galaxia_user_can_clean_instances()) )
    {
      $this->error[] = tra('user is not authorized to delete instances');
      return false;
    }
    $query="select `wf_instance_id` from `".GALAXIA_TABLE_PREFIX."instances` where `wf_p_id`=?";
    // start a transaction
    $this->db->StartTrans();
    $result = $this->query($query,array($pId));
    while($res = $result->fetchRow()) {
      $iid = $res['wf_instance_id'];
      $query = "delete from `".GALAXIA_TABLE_PREFIX."instance_activities` where `wf_instance_id`=?";
      $this->query($query,array($iid));
      $query = "delete from `".GALAXIA_TABLE_PREFIX."workitems` where `wf_instance_id`=?";
      $this->query($query,array($iid));
    }
    $query = "delete from `".GALAXIA_TABLE_PREFIX."instances` where `wf_p_id`=?";
    $this->query($query,array($pId));
    // perform commit (return true) or Rollback (return false)
    return $this->db->CompleteTrans();
  }

  /*! list all process
  * List all processes and return stats
  * @param $offset is the first row number to return
  * @param $maxRecords is the maximumnumber of records to return
  * @param $sort_mode is the sort order
  * @param $find is a string to search for in process name or process description
  * @param $where is a string to ad to the query, be carefull with this string, read the query before
  * @param $add_stats is true by default, by setting it to false you wont get the statistics associated with
  * the processes, this could be helpfull for gui listing on selects, to avoid (a big number of) unnecessary queries
  * @return an associative array with the number of records for the 'cant' key and an array of process stats for the
  * 'data' key. each row is of this form:
  *	* key : process_id
  *	* value : an array of infos:
  *		* keys are : wf_p_id, wf_name, wf_is_valid, wf_is_active, wf_version, wf_description, wf_last_modif,
  *		and  wf_normalized_name for the 'classical part' and for the 'stats part' whe have: active_instances,
  *		exception_instances, completed_instances, aborted_instances, all_instances, activities
  */
  function monitor_list_processes($offset,$maxRecords,$sort_mode,$find,$where='', $add_stats=true)
  {

    $sort_mode = $this->convert_sortmode($sort_mode);
    if($find) {
      $findesc = '%'.$find.'%';
      $mid=" where ((wf_name like ?) or (wf_description like ?))";
      $bindvars = array($findesc,$findesc);
    } else {
      $mid="";
      $bindvars = array();
    }
    if($where) {
      if($mid) {
        $mid.= " and ($where) ";
      } else {
        $mid.= " where ($where) ";
      }
    }
    // get the requested processes
    $query = "select * from ".GALAXIA_TABLE_PREFIX."processes $mid order by $sort_mode";
    $query_cant = "select count(*) from ".GALAXIA_TABLE_PREFIX."processes $mid";
    $result = $this->query($query,$bindvars,$maxRecords,$offset);
    $cant = $this->getOne($query_cant,$bindvars);
    $ret = Array();
    while($res = $result->fetchRow()) {
      $pId = $res['wf_p_id'];
      // Number of active instances
      $res['active_instances'] = 0;
      // Number of exception instances
      $res['exception_instances'] = 0;
      // Number of completed instances
      $res['completed_instances'] = 0;
      // Number of aborted instances
      $res['aborted_instances'] = 0;
      $res['all_instances'] = 0;
      // Number of activities
      $res['activities'] = 0;
      $ret[$pId] = $res;
    }
    if (count($ret) < 1) {
      $retval = Array();
      $retval["data"] = $ret;
      $retval["cant"] = $cant;
      return $retval;
    }
    if ($add_stats)
    {
      // get number of instances and timing statistics per process and status
      $query = "select wf_p_id, wf_status, count(*) as num_instances,
                min(wf_ended - wf_started) as min_time, avg(wf_ended - wf_started) as avg_time, max(wf_ended - wf_started) as max_time
                from ".GALAXIA_TABLE_PREFIX."instances where wf_p_id in (" . join(', ', array_keys($ret)) . ") group by wf_p_id, wf_status";
      $result = $this->query($query);
      while($res = $result->fetchRow()) {
        $pId = $res['wf_p_id'];
        if (!isset($ret[$pId])) continue;
        switch ($res['wf_status']) {
          case 'active':
            $ret[$pId]['active_instances'] = $res['num_instances'];
            $ret[$pId]['all_instances'] += $res['num_instances'];
            break;
          case 'completed':
            $ret[$pId]['completed_instances'] = $res['num_instances'];
            $ret[$pId]['all_instances'] += $res['num_instances'];
            $ret[$pId]['duration'] = array('min' => $res['min_time'], 'avg' => $res['avg_time'], 'max' => $res['max_time']);
            break;
          case 'exception':
            $ret[$pId]['exception_instances'] = $res['num_instances'];
            $ret[$pId]['all_instances'] += $res['num_instances'];
            break;
          case 'aborted':
            $ret[$pId]['aborted_instances'] = $res['num_instances'];
            $ret[$pId]['all_instances'] += $res['num_instances'];
            break;
        }
      }
      // get number of activities per process
      $query = "select wf_p_id, count(*) as num_activities
                from ".GALAXIA_TABLE_PREFIX."activities
                where wf_p_id in (" . join(', ', array_keys($ret)) . ")
                group by wf_p_id";
      $result = $this->query($query);
      while($res = $result->fetchRow()) {
        $pId = $res['wf_p_id'];
        if (!isset($ret[$pId])) continue;
        $ret[$pId]['activities'] = $res['num_activities'];
      }
    }
    $retval = Array();
    $retval["data"] = $ret;
    $retval["cant"] = $cant;
    return $retval;
  }

  /*! list all activities
  * List all activities and return stats
  * @param $offset is the first row number to return
  * @param $maxRecords is the maximumnumber of records to return
  * @param $sort_mode is the sort order
  * @param $find is a string to search for in activity name or activity description
  * @param $where is a string to ad to the query, be carefull with this string, read the query before
  * @param $add_stats is true by default, by setting it to false you wont get the statistics associated with
  * the activities, this could be helpfull for gui listing on selects, to avoid (a big number of) unnecessary queries
  * @return an associative array with the number of records for the 'cant' key and an array of process stats for the
  * 'data' key. each row is of this form:
  *	* key : activity_id
  *	* value : an array of infos:,
  *		* keys are : wf_procname, wf_version, wf_proc_normalized_name, wf_activity_id, wf_name, wf_normalized_name, wf_p_id, wf_type
  *		wf_is_autorouted, wf_flow_num, wf_is_interactive, wf_last_modif, wf_description, wf_default_user
  *		and for the stats part: active_instances, completed_instances ,aborted_instances, exception_instances
  *		act_running_instances, act_completed_instances
  */
  function monitor_list_activities($offset,$maxRecords,$sort_mode,$find,$where='', $add_stats=true)
  {

    $sort_mode = $this->convert_sortmode($sort_mode);
    if($find) {
      $findesc = '%'.$find.'%';
      $mid=" where ((ga.wf_name like ?) or (ga.wf_description like ?))";
      $bindvars = array($findesc,$findesc);
    } else {
      $mid="";
      $bindvars = array();
    }
    if($where) {
      $where = preg_replace('/pId/', 'ga.wf_p_id', $where);
      if($mid) {
        $mid.= " and ($where) ";
      } else {
        $mid.= " where ($where) ";
      }
    }
    $query = "select gp.`wf_name` as `wf_procname`, gp.`wf_version`, gp.wf_normalized_name as wf_proc_normalized_name, ga.*
              from ".GALAXIA_TABLE_PREFIX."activities ga
                left join ".GALAXIA_TABLE_PREFIX."processes gp on gp.wf_p_id=ga.wf_p_id
              $mid order by $sort_mode";
    $query_cant = "select count(*) from ".GALAXIA_TABLE_PREFIX."activities ga $mid";
    $result = $this->query($query,$bindvars,$maxRecords,$offset);
    $cant = $this->getOne($query_cant,$bindvars);
    $ret = Array();
    while($res = $result->fetchRow()) {
      // Number of active instances
      $aid = $res['wf_activity_id'];
      if ($add_stats)
      {
        $res['active_instances']=$this->getOne("select count(gi.wf_instance_id) from ".GALAXIA_TABLE_PREFIX."instances gi,".GALAXIA_TABLE_PREFIX."instance_activities gia where gi.wf_instance_id=gia.wf_instance_id and gia.wf_activity_id=$aid and gi.wf_status='active' and wf_p_id=".$res['wf_p_id']);
      // activities of completed instances are all removed from the instance_activities table for some reason, so we need to look at workitems
        $res['completed_instances']=$this->getOne("select count(distinct gi.wf_instance_id) from ".GALAXIA_TABLE_PREFIX."instances gi,".GALAXIA_TABLE_PREFIX."workitems gw where gi.wf_instance_id=gw.wf_instance_id and gw.wf_activity_id=$aid and gi.wf_status='completed' and wf_p_id=".$res['wf_p_id']);
      // activities of aborted instances are all removed from the instance_activities table for some reason, so we need to look at workitems
        $res['aborted_instances']=$this->getOne("select count(distinct gi.wf_instance_id) from ".GALAXIA_TABLE_PREFIX."instances gi,".GALAXIA_TABLE_PREFIX."workitems gw where gi.wf_instance_id=gw.wf_instance_id and gw.wf_activity_id=$aid and gi.wf_status='aborted' and wf_p_id=".$res['wf_p_id']);
        $res['exception_instances']=$this->getOne("select count(gi.wf_instance_id) from ".GALAXIA_TABLE_PREFIX."instances gi,".GALAXIA_TABLE_PREFIX."instance_activities gia where gi.wf_instance_id=gia.wf_instance_id and gia.wf_activity_id=$aid and gi.wf_status='exception' and wf_p_id=".$res['wf_p_id']);
        $res['act_running_instances']=$this->getOne("select count(gi.wf_instance_id) from ".GALAXIA_TABLE_PREFIX."instances gi,".GALAXIA_TABLE_PREFIX."instance_activities gia where gi.wf_instance_id=gia.wf_instance_id and gia.wf_activity_id=$aid and gia.wf_status='running' and wf_p_id=".$res['wf_p_id']);
      // completed activities are removed from the instance_activities table unless they're part of a split for some reason, so this won't work
      //  $res['act_completed_instances']=$this->getOne("select count(gi.wf_instance_id) from ".GALAXIA_TABLE_PREFIX."instances gi,".GALAXIA_TABLE_PREFIX."instance_activities gia where gi.wf_instance_id=gia.wf_instance_id and gia.activityId=$aid and gia.status='completed' and pId=".$res['pId']);
        $res['act_completed_instances'] = 0;
      }
      $ret[$aid] = $res;
    }
    if (count($ret) < 1) {
      $retval = Array();
      $retval["data"] = $ret;
      $retval["cant"] = $cant;
      return $retval;
    }
    if ($add_stats)
    {
      $query = "select wf_activity_id, count(distinct wf_instance_id) as num_instances, min(wf_ended - wf_started) as min_time, avg(wf_ended - wf_started) as avg_time, max(wf_ended - wf_started) as max_time
                from ".GALAXIA_TABLE_PREFIX."workitems
                where wf_activity_id in (" . join(', ', array_keys($ret)) . ")
                group by wf_activity_id";
      $result = $this->query($query);
      while($res = $result->fetchRow()) {
        // Number of active instances
        $aid = $res['wf_activity_id'];
        if (!isset($ret[$aid])) continue;
        $ret[$aid]['act_completed_instances'] = $res['num_instances'] - $ret[$aid]['aborted_instances'];
        $ret[$aid]['duration'] = array('min' => $res['min_time'], 'avg' => $res['avg_time'], 'max' => $res['max_time']);
      }
    }
    $retval = Array();
    $retval["data"] = $ret;
    $retval["cant"] = $cant;
    return $retval;
  }

  //! list all instances
  function monitor_list_instances($offset,$maxRecords,$sort_mode,$find,$where='', $addstats=true)
  {
    $wherevars = array();
    if($find) {
      $findesc = $this->qstr('%'.$find.'%');
      $mid=' where ((`wf_properties` like ?) or (gi.`wf_name` like ?)
        or (ga.`wf_name` like ?) or (gp.`wf_name` like ?))';
        $wherevars[] = $findesc;
        $wherevars[] = $findesc;
        $wherevars[] = $findesc;
        $wherevars[] = $findesc;
    } else {
      $mid='';
    }
    if($where) {
      if($mid) {
        $mid.= " and ($where) ";
      } else {
        $mid.= " where ($where) ";
      }
    }

    $query = 'select gp.wf_p_id, ga.wf_is_interactive,gp.wf_normalized_name as wf_proc_normalized_name, gi.wf_owner, gp.wf_name as wf_procname, gp.wf_version, ga.wf_type,';
    $query.= ' ga.wf_activity_id, ga.wf_name as wf_activity_name, gi.wf_instance_id, gi.wf_name as wf_instance_name, gi.wf_status, gia.wf_activity_id, gia.wf_user, gi.wf_started, gi.wf_ended, gia.wf_status as wf_act_status ';
    $query.= ' from `'.GALAXIA_TABLE_PREFIX.'instances` gi LEFT JOIN `'.GALAXIA_TABLE_PREFIX.'instance_activities` gia ON gi.`wf_instance_id`=gia.`wf_instance_id` ';
    $query.= 'LEFT JOIN `'.GALAXIA_TABLE_PREFIX.'activities` ga ON gia.`wf_activity_id` = ga.`wf_activity_id` ';
    $query.= 'LEFT JOIN `'.GALAXIA_TABLE_PREFIX."processes` gp ON gp.`wf_p_id`=gi.`wf_p_id` $mid";

    $query_cant = 'select count(*) from `'.GALAXIA_TABLE_PREFIX.'instances` gi LEFT JOIN `'.GALAXIA_TABLE_PREFIX.'instance_activities` gia ON gi.`wf_instance_id`=gia.`wf_instance_id` ';
    $query_cant.= 'LEFT JOIN `'.GALAXIA_TABLE_PREFIX.'activities` ga ON gia.`wf_activity_id` = ga.`wf_activity_id` LEFT JOIN `'.GALAXIA_TABLE_PREFIX."processes` gp ON gp.`wf_p_id`=gi.`wf_p_id` $mid";
    $result = $this->query($query,$wherevars,$maxRecords,$offset,true,$this->convert_sortmode($sort_mode));
    $cant = $this->getOne($query_cant,$wherevars);
    $ret = Array();
    while($res = $result->fetchRow()) {
      $iid = $res['wf_instance_id'];
      $res['workitems']=$this->getOne('select count(*) from `'.GALAXIA_TABLE_PREFIX.'workitems` where `wf_instance_id`=?',array($iid));
      $ret[$iid] = $res;
    }
    $retval = Array();
    $retval['data'] = $ret;
    $retval['cant'] = $cant;
    return $retval;
  }

  //! list all processes
  function monitor_list_all_processes($sort_mode = 'wf_name_asc', $where = '') {
    if (!empty($where)) {
      $where = " where ($where) ";
    }
    $query = "select `wf_name`,`wf_version`,`wf_p_id` from `".GALAXIA_TABLE_PREFIX."processes` $where order by ".$this->convert_sortmode($sort_mode);
    $result = $this->query($query);
    $ret = Array();
    while($res = $result->fetchRow()) {
      $pId = $res['wf_p_id'];
      $ret[$pId] = $res;
    }
    return $ret;
  }

  //! list all activities
  function monitor_list_all_activities($sort_mode = 'wf_name_asc', $where = '') {
    if (!empty($where)) {
      $where = " where ($where) ";
    }
    $query = "select `wf_name`,`wf_activity_id` from `".GALAXIA_TABLE_PREFIX."activities` $where order by ".$this->convert_sortmode($sort_mode);
    $result = $this->query($query);
    $ret = Array();
    while($res = $result->fetchRow()) {
      $aid = $res['wf_activity_id'];
      $ret[$aid] = $res;
    }
    return $ret;
  }

  //! list instances status we have in the database.
  function monitor_list_statuses() {
    $query = "select distinct(`wf_status`) from `".GALAXIA_TABLE_PREFIX."instances`";
    $result = $this->query($query);
    $ret = Array();
    while($res = $result->fetchRow()) {
      $ret[] = $res['wf_status'];
    }
    return $ret;
  }

  //! list all users associated with instances avaible in the actual database
  function monitor_list_users() {
    $query = "select distinct(`wf_user`) from `".GALAXIA_TABLE_PREFIX."instance_activities`";
    $result = $this->query($query);
    $ret = Array();
    while($res = $result->fetchRow()) {
      $ret[] = $res['wf_user'];
    }
    return $ret;
  }

  //! list all user associated with workitems avaible in the actual database
  function monitor_list_wi_users() {
    $query = "select distinct(`wf_user`) from `".GALAXIA_TABLE_PREFIX."workitems`";
    $result = $this->query($query);
    $ret = Array();
    while($res = $result->fetchRow()) {
      $ret[] = $res['wf_user'];
    }
    return $ret;
  }

  //! list all intance owner we have in the actual databse
  function monitor_list_owners() {
    $query = "select distinct(`wf_owner`) from `".GALAXIA_TABLE_PREFIX."instances`";
    $result = $this->query($query);
    $ret = Array();
    while($res = $result->fetchRow()) {
      $ret[] = $res['wf_owner'];
    }
    return $ret;
  }

  //! list all activity types we have in the actual database (used activity types)
  function monitor_list_activity_types() {
    $query = "select distinct(`wf_type`) from `".GALAXIA_TABLE_PREFIX."activities`";
    $result = $this->query($query);
    $ret = Array();
    while($res = $result->fetchRow()) {
      $ret[] = $res['wf_type'];
    }
    return $ret;
  }

  //! return an array containing information about a given workitem
  /*!
  * @param itemId is the workitem Id
  */
  function monitor_get_workitem($itemId) {
    $query = "select gw.`wf_order_id`,ga.`wf_name`,ga.`wf_type`,ga.`wf_is_interactive`,gp.`wf_name` as `wf_wf_procname`,gp.`wf_version`,";
    $query.= "gw.`wf_item_id`,gw.`wf_properties`,gw.`wf_user`,`wf_started`,`wf_ended`-`wf_started` as wf_duration ";
    $query.= "from `".GALAXIA_TABLE_PREFIX."workitems` gw,`".GALAXIA_TABLE_PREFIX."activities` ga,`".GALAXIA_TABLE_PREFIX."processes` gp where ga.`wf_activity_id`=gw.`wf_activity_id` and ga.`wf_p_id`=gp.`wf_p_id` and `wf_item_id`=?";
    $result = $this->query($query, array($itemId));
    $res = $result->fetchRow();
    $res['wf_properties'] = unserialize($res['wf_properties']);
    return $res;
  }

  //! List workitems per instance
  /*!
  *
  */
  function monitor_list_workitems($offset,$maxRecords,$sort_mode,$find,$where='',$wherevars=array()) {
    $mid = '';
    if ($where) {
      $mid.= " and ($where) ";
    }
    if($find) {
      $findesc = $this->qstr('%'.$find.'%');
      $mid.=" and ((`wf_properties` like $findesc) or (gp.wf_name like $findesc) or (ga.wf_name like $findesc))";
    }
// TODO: retrieve instance status as well
    $query = 'select wf_item_id,wf_ended-wf_started as wf_duration,ga.wf_is_interactive, ga.wf_type,gp.wf_name as wf_procname,gp.wf_version,gp.wf_normalized_name as wf_proc_normalized_name,ga.wf_name as wf_act_name,';
    $query.= 'ga.wf_activity_id,wf_instance_id,wf_order_id,wf_properties,wf_started,wf_ended,wf_user';
    $query.= ' from '.GALAXIA_TABLE_PREFIX.'workitems gw,'.GALAXIA_TABLE_PREFIX.'activities ga,'.GALAXIA_TABLE_PREFIX.'processes gp';
    $query.= ' where gw.wf_activity_id=ga.wf_activity_id and ga.wf_p_id=gp.wf_p_id '.$mid.' order by '.$this->convert_sortmode($sort_mode);
    $query_cant = "select count(*) from `".GALAXIA_TABLE_PREFIX."workitems` gw,`".GALAXIA_TABLE_PREFIX."activities` ga,`".GALAXIA_TABLE_PREFIX."processes` gp where gw.`wf_activity_id`=ga.`wf_activity_id` and ga.`wf_p_id`=gp.`wf_p_id` $mid";
    $result = $this->query($query,$wherevars,$maxRecords,$offset);
    $cant = $this->getOne($query_cant,$wherevars);
    $ret = Array();
    while($res = $result->fetchRow()) {
      $itemId = $res['wf_item_id'];
      $ret[$itemId] = $res;
    }
    $retval = Array();
    $retval["data"] = $ret;
    $retval["cant"] = $cant;
    return $retval;
  }


}
?>
