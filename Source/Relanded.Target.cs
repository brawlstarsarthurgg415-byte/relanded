using UnrealBuildTool;
using System.Collections.Generic;

public class RelandedTarget : TargetRules
{
    public RelandedTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Game;
        DefaultBuildSettings = BuildSettingsVersion.V5;
        IncludeOrderVersion = EngineIncludeOrderVersion.Unreal5_5;
        ExtraModuleNames.Add("Relanded");
    }
}
