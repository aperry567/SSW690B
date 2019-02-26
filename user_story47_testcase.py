import user_story47 as user
import unittest
import datetime

# Test Case

class user_story47_Test(unittest.TestCase):

    def test_MarriedDates(self):  # testCase for Check Married
            self.assertEqual(user.Marriage_befor_divorce(family_list), 0)

    def test_DivorcedDates(self):  # testCase for Check Divorce
        today = datetime.today()
        for i in family_list:
                if i[4] != "NA":
                        self.assertLess(datetime.strptime(i[4], "%Y %b %d"), today)



if __name__ == '__main__':
    unittest.main(exit=False, verbosity=2)