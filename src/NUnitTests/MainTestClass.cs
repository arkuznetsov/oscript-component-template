using NUnit.Framework;
using oscriptcomponent;
using System.Collections.Generic;
using ScriptEngine.HostedScript.Library;

// Используется NUnit 3.6

namespace NUnitTests
{
	[TestFixture]
	public class MainTestClass
	{

		private EngineHelpWrapper _host;

		public static List<TestCaseData> TestCases
		{
			get
			{
				var testCases = new List<TestCaseData>();
				EngineHelpWrapper _host = new EngineHelpWrapper();
				_host.StartEngine();

				ArrayImpl testMethods =_host.GetTestMethods("NUnitTests.Tests.external.os");

				foreach (var ivTestMethod in testMethods)
				{
					testCases.Add(new TestCaseData(ivTestMethod.ToString()));
				}

				return testCases;
			}
		}
		
		[OneTimeSetUp]
		public void Initialize()
		{
			_host = new EngineHelpWrapper();
			_host.StartEngine();
		}

		[Test]
		[Category("Test internal object")]
		public void TestAsInternalObjects()
		{
			var item1 = new CalcItem(1);
			var item2 = new CalcItem(2);
			var sum = new Calculation();

			sum.AddItem(item1);
			sum.AddItem(item2);

			Assert.AreEqual(sum.Calculate(), 3);

			sum.AddItem(new CalcItem(3));
			Assert.AreEqual(sum.Calculate(), 6);

			sum.AddItem(new CalcItem(-1));
			Assert.AreEqual(sum.Calculate(), 5);
		}

		[Test]
		[Category("Test internal collection")]
		public void TestAsInternalCollection()
		{
			var item1 = new CalcItem(1);
			var item2 = new CalcItem(2);
			var sum = new Calculation();

			sum.AddItem(item1);
			sum.AddItem(item2);

			foreach (var item in sum)
			{
				// В случае, если Addition не воплощает IEnumerable,
				// этот цикл не скомпилируется
			}
		}
	
		[TestCaseSource(nameof(TestCases))]
		[Category("OneScript tests")]
		public void TestAsExternalObjects(string testCase)
		{
			string testException;

			int result = _host.RunTestMethod("NUnitTests.Tests.external.os", testCase, out testException);
			
			switch (result)
			{
				case -1:
					Assert.Ignore("Тест: {0} не реализован!", testCase);
					break;
				case 0:
					Assert.Pass();
					break;
				case 1:
					Assert.Fail("Тест: {0} провален с сообщением: {1}", testCase, testException);
					break;
				default:
					Assert.Inconclusive("Тест: {0} вернул неожиданный результат: {1}", testCase, result);
					break;
			}
		}
	}
}
