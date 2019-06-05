#include <iostream>

#include "tests.h"


using namespace std;

int main()
{
    Tests tests;
   if(tests.run_tests())
   {
       printf("SUCCESS! TESTS PASSED\n");
   }


    return 0;
}
