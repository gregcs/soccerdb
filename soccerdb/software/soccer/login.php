<?php

$pageName = "SoccerDB - Login";

include "includes/header.php";
?>

<?php
if (isset($_SESSION["db_user_id"])) {
  header("Location: index.php", true, 301);
  exit();
}
?>

<?php
$error = false;
if (isset($_POST["loginSubmit"])) {
  $username = $_POST["username"];
  $password = $_POST["password"];
  $credentials = [$username, $password];
  include_once("functions/user.php");
  if (login($credentials)) {
    header("Location: index.php", true, 301);
    exit();
  } else {
    $error = true;
  }
}
?>

<?php if (!isset($_SESSION["db_user_id"])) { ?>


<style>
    #logIn {
        position: absolute;
        top: 50%;
        left: 50%;
        -webkit-transform: translate(-50%, -50%);
        transform: translate(-50%, -50%);
    }
</style>

<form method="post" action="<?php $_SERVER['PHP_SELF'] ?>">

    <div id="logIn" class="col-xs-10 col-xs-push-1 col-sm-3 col-sm-push-4">
        <div class="panel panel-default">
            <div class="panel-body">
                <div class="form-group">
                    <label>Username</label>
                    <input name="username" type="text" class="form-control" placeholder="Insert username">
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input name="password" type="password" class="form-control" placeholder="Insert password">
                </div>
                <?php if ($error) { ?>
                <div class="form-group" style="text-align:center;">
                    <label class="text-danger">Log in failed!</label>
                </div>
                <?php 
              } ?>
                <div class="form-group" style="text-align:center;">
                    <button name="loginSubmit" type="submit" class="btn btn-primary">Accedi</button>
                </div>
            </div>
        </div>
    </div>

</form>

<?php 
} ?>



<?php
include "includes/footer.php";
?> 