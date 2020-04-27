package cl.lramirez.istio.demoistio;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController

public class DemoIstioController {

	@GetMapping(path = "/version")
	public Version version(@RequestHeader(value = "User-Agent") String userAgent) {
		System.out.println("Conectado desde :" + userAgent);
		Version version = new Version();
		version.setId("V4.4.4");
		version.setDescripcion("Esta es la tercera version 4.4.4");
		return version;
	}

}
