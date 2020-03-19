package org.funqy.demo;

import io.quarkus.funqy.Funq;
import org.jboss.logging.Logger;

import javax.inject.Inject;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;

public class GreetingFunctions {
    private static final Logger log = Logger.getLogger("funqy.greeting");
    @Inject
    GreetingService service;

    @Funq
    public CompletionStage<Greeting> greet(Identity name) {
        log.info("*** In greeting service ***");
        String message = service.hello(name.getName());
        log.info("Sending back: " + message);
        Greeting greeting = new Greeting();
        greeting.setMessage(message);
        greeting.setName(name.getName());

        CompletableFuture<Greeting> result = new CompletableFuture<>();

        Timer timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                result.complete(greeting);
            }
        }, 3000);

        return result;
    }

}
