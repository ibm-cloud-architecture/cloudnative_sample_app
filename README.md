### Requirements
* [Maven](https://maven.apache.org/install.html)
* Java 8: Any compliant JVM should work.
  * [Java 8 JDK from Oracle](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
  * [Java 8 JDK from IBM (AIX, Linux, z/OS, IBM i)](http://www.ibm.com/developerworks/java/jdk/)

### Run

To build and run the application:
1. `mvn install`
2. `java -jar ./target/cloudnativesampleapp-1.0-SNAPSHOT.jar`
3. Try the App endpoint http://localhost:9080/greeting?name=Carlos
