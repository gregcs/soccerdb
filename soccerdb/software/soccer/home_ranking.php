<?php

$pageName = "SoccerDB - Rankings";
$title = "Rankings";

include "includes/header.php";

include_once("functions/db.php");
include_once("functions/league.php");
include_once("includes/pagination.php");

$db = dbconnect();

$query = "
SELECT DISTINCT L.name, L.country, M.season
FROM league AS L
JOIN match AS M
ON M.league = L.name
ORDER BY L.name,M.season";

$limit = (isset($_GET['limit'])) ? $_GET['limit'] : 10;
$page = (isset($_GET['page'])) ? $_GET['page'] : 1;
$links = 5;
$paginator = new Paginator($db, $query);
$results = $paginator->getData($limit, $page);

?>

<style>
    #contentContainer {
        padding: 15px;
        padding-top: 0px;
        text-align: center;
    }

    table thead tr th {
        text-align: center;
    }


</style>

<div id="contentContainer" class="container-fluid">

    <ol class="breadcrumb">
        <li><a href="index.php">Home</a></li>
        <li class="active"><?php echo $title ?></li>
    </ol>

    <div class="page-header">
        <h1><?php echo $title ?></h1>
    </div>

    <div class="row">
        <div class="col-sm-12">

        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="col-sm-4 col-sm-push-4">
                <?php if (!empty($results->data)) { ?>
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>League</th>
                                <th>Country</th>
                                <th>Season</th>
                                <th></th>
                            </tr>
                        <tbody>
                            <?php foreach ($results->data as $row) { ?>

                            <tr>
                                <td><?php echo $row["name"] ?></td>
                                <td><?php echo $row["country"] ?></td>
                                <td><?php echo $row["season"] ?></td>
                                <td><a data-toggle="tooltip" data-placement="bottom" title="View season ranking" href="ranking.php?league=<?php echo $row["name"] ?>&season=<?php echo $row["season"] ?>" target="blank"><span class="glyphicon glyphicon-king" style="color:#2980b9;" aria-hidden="true"></span></a></td>
                            </tr>
                            <?php 
                        } ?>
                        </tbody>
                        </thead>
                    </table>
                </div>
                <?php

            } else { ?>
                <div class="panel panel-primary">
                    <div class="panel-body">
                        There are no leagues to display
                    </div>
                </div>
                <?php 
            } ?>
            </div>
        </div>
    </div>

    <?php if (!empty($results->data)) { ?>
    <div class="row">
        <div class="col-sm-12">
            <div class="col-sm-6 col-sm-push-3">
                <?php
                echo $paginator->createLinks($links, 'pagination pagination-md');
                ?>
            </div>
        </div>
    </div>
    <?php 
} ?>

</div>

<?php
include "includes/basic_scripts.php";
?>

<script>
    $(document).ready(function() {
        $('[data-toggle="tooltip"]').tooltip();
    });
</script>

<?php
include "includes/footer.php"
?> 