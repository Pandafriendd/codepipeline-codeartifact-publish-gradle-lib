import static org.junit.Assert.assertEquals;
import org.junit.Test;
 
public class TemperatureCalculatorTest {
    @Test
    public void testToDegree(){
        TemperatureCalculator calculator = new TemperatureCalculator();
        assertEquals(36.666668f,calculator.toDegree(98),0);
    }
 
   // @Test
   // public void testToFahrenheit(){
     //   TemperatureCalculator calculator = new TemperatureCalculator();
      //  assertEquals("Test failed for Degree to Fahrenheit",100f,calculator.toFahrenheit(100),0);
  //  }
}
