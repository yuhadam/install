package controllers

import javax.inject._
import play.api._
import play.api.mvc._
import play.api.Logger
import play.api.libs.json._
import scala.sys.process._

/**
 * This controller creates an `Action` to handle HTTP requests to the
 * application's home page.
 */
@Singleton
class HomeController @Inject() extends Controller {

  /**
   * Create an Action to render an HTML page with a welcome message.
   * The configuration in the `routes` file means that this method
   * will be called when the application receives a `GET` request with
   * a path of `/`.
   */
  def index = Action {
    Ok(views.html.index())
  }
  
  def install = Action { implicit request =>
    val data = request.body.asFormUrlEncoded.get("data")(0)
    val json = Json.parse(data)
    val interfaceval = (json \ "interfaceval").as[String]
    val passwordval = (json \ "passwordval").as[String]
    val sshportval = (json \ "sshportval").as[String]
    val masteriparr = (json \ "masteriparr").as[List[JsValue]]
    val workeriparr = (json \ "workeriparr").as[List[JsValue]]
    
    val commandstr = "bash /install/install_bootstrap.sh " + interfaceval + " " + passwordval + " " + sshportval+" "
    Logger.debug(json.toString())
    
    
    val newStr = masteriparr.foldLeft(commandstr)((m:String,n:JsValue) => {m + n.as[String]  +" "})
    val lastStr = workeriparr.foldLeft(newStr)((m:String,n:JsValue) => m + n.toString()+" ")
    
    
    Logger.debug(lastStr)
    
    Process(lastStr).run
    
    Ok("hi")
  }

}
