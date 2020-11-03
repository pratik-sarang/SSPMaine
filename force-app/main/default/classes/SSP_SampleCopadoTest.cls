/**
 * Test class for sample class 'SSP_SampleCopado' used to check deployment via Copado
 */
@isTest
public class SSP_SampleCopadoTest {

    static testmethod void shouldCallSampleMethod() {
        Integer returnVal = SSP_SampleCopado.sampleMethod(2, 3);
        
        System.assertEquals(5, returnVal, 'Correct value');
    }
}