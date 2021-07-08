<?php

class Paginator
{

	private $_conn;
	private $_limit;
	private $_page;
	private $_query;
	private $_total;
	private $_row_start;


	public function __construct($conn, $query)
	{
		$this->_conn = $conn;
		$this->_query = $query;

		$rs = pg_query($this->_conn, $this->_query);
		$this->_total = pg_num_rows($rs);
	}

	public function getData($limit = 10, $page = 1){
		$this->_limit =$limit;
		$this->_page = $page;

		if($this->_limit == 'all'){
			$query = $this->_query;
		}else{
			$this->_row_start = ((($this->_page)-1) * $this->_limit);
			$query = ($this->_query)." OFFSET ".$this->_row_start." LIMIT ".$this->_limit;
		}

		$rs = pg_query($this->_conn, $query);

		while($row = pg_fetch_assoc($rs)){
			$results[] = $row;
		}
		
		$result = new stdClass();
		$result->page = $this->_page;
		$result->limit = $this->_limit;
		$result->total = $this->_total;
		$result->data = isset($results) ? $results : [];

		return $result;
	}


	public function createLinks($links, $list_class){

		if($this->_limit == 'all'){
			return '';
		}

		$last = ceil($this->_total/$this->_limit);
		$start = (($this->_page - $links)>0) ? $this->_page - $links : 1;
		$end = (($this->_page + $links) < $last) ? $this->_page + $links : $last;

		$html = '<ul class="' .$list_class.'">';
		$class = ($this->_page == 1) ? "disabled" : "";
		$previus_page = ($this->_page == 1) ?
		'<a href=""><li class="'.$class.'">&laquo;</a></li>' :
		'<li class0"'.$class.'"><a href="?limit='.$this->_limit.'&page='.($this->_page-1).'">&laquo;</a></li>';

		$html .= $previus_page;

		if($start > 1){
			$html .= '<li><a href="?limit='. $this->_limit.'&page=1">1</a></li>';
			$html .= '<li class="disabled"><span>...</span></li>';
		}

		for($i = $start; $i <=$end; $i++){
			$class = ($this->_page == $i) ? "active" : "";
			$html .= '<li class="'.$class.'"><a href="?limit='.$this->_limit.'&page='.$i.'">'.$i.'</a></li>';
		}

		if($end<$last){
			$html .= '<li class="disabled"><span>...</span></li>';
			$html .= '<li><a href="?limit='.$this->_limit.'&page='.$last .'">'.$last.'</a></li>';
		}

		$class =($this->_page == $last)?"disabled":"";

		$next_page =($this->_page == $last) ?
		'<li class="'.$class.'"><a href="">&raquo;</a></li>' :
		'<li class="'.$class.'"><a href="?limit="'.$this->_limit .'&page='.($this->_page+1) . '">&raquo;</a></li>';

		$html .= $next_page;
		$html .='</ul>';

		return $html;
	}

}
 


  