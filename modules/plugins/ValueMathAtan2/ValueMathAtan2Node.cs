#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "MathAtan2", Category = "Value", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class ValueMathAtan2Node : IPluginEvaluate
	{
		#region fields & pins
		[Input("X", DefaultValue = 1.0)]
		ISpread<double> FXIn;
		
		[Input("Y", DefaultValue = 1.0)]
		ISpread<double> FYIn;

		[Output("Output")]
		ISpread<double> FOutput;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FOutput.SliceCount = SpreadMax;

			for (int i = 0; i < SpreadMax; i++)
				FOutput[i] = Math.Atan2(FYIn[i], FXIn[i]);

			//FLogger.Log(LogType.Debug, "hi tty!");
		}
	}
}
