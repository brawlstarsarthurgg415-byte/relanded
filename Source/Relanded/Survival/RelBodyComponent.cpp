#include "Survival/RelBodyComponent.h"

URelBodyComponent::URelBodyComponent()
{
    PrimaryComponentTick.bCanEverTick = true;
    PartHealth.Init(100.f, 6);
}

bool URelBodyComponent::IsValidPart(ERelBodyPart Part) const
{
    return static_cast<uint8>(Part) < 6;
}

float URelBodyComponent::GetPartHealth(ERelBodyPart Part) const
{
    return IsValidPart(Part) && PartHealth.IsValidIndex(static_cast<int32>(Part))
        ? PartHealth[static_cast<int32>(Part)] : 0.f;
}

void URelBodyComponent::SetPart(ERelBodyPart Part, float NewValue)
{
    if (!IsValidPart(Part) || bDead) return;
    const int32 Index = static_cast<int32>(Part);
    float& Value = PartHealth[Index];
    NewValue = FMath::Clamp(NewValue, 0.f, 100.f);
    if (FMath::IsNearlyEqual(Value, NewValue, 0.01f)) return;
    Value = NewValue;
    OnPartChanged.Broadcast(Part, Value);

    if (PartHealth[static_cast<int32>(ERelBodyPart::Head)] <= 0.f ||
        PartHealth[static_cast<int32>(ERelBodyPart::Torso)] <= 0.f)
    {
        bDead = true;
        OnFatalInjury.Broadcast();
    }
}

void URelBodyComponent::DamagePart(ERelBodyPart Part, float Amount)
{
    if (!IsValidPart(Part) || Amount <= 0.f || bDead) return;
    SetPart(Part, GetPartHealth(Part) - Amount);
}

void URelBodyComponent::DamageRandomPart(float Amount)
{
    if (Amount <= 0.f || bDead) return;
    const float R = FMath::FRand();
    const ERelBodyPart Part = R < .15f ? ERelBodyPart::Head : R < .50f ? ERelBodyPart::Torso :
        R < .62f ? ERelBodyPart::LeftArm : R < .75f ? ERelBodyPart::RightArm :
        R < .88f ? ERelBodyPart::LeftLeg : ERelBodyPart::RightLeg;
    DamagePart(Part, Amount * 2.5f);
}

void URelBodyComponent::Poison(ERelBodyPart Part)
{
    if (!IsValidPart(Part) || bDead) return;
    bPoisoned = true;
    PoisonedPart = Part;
}

void URelBodyComponent::ApplyMedicine(ERelBodyPart Part, float HealAmount)
{
    if (!IsValidPart(Part) || HealAmount <= 0.f || bDead) return;
    SetPart(Part, GetPartHealth(Part) + HealAmount);
    if (bPoisoned && PoisonedPart == Part) bPoisoned = false;
}

bool URelBodyComponent::ApplySplint(ERelBodyPart Part)
{
    if (!IsValidPart(Part) || Part == ERelBodyPart::Head || Part == ERelBodyPart::Torso || bDead) return false;
    SetPart(Part, FMath::Max(GetPartHealth(Part), 55.f));
    return true;
}

float URelBodyComponent::GetMoveSpeedMultiplier() const
{
    const int32 HurtLegs = (GetPartHealth(ERelBodyPart::LeftLeg) < CriticalThreshold ? 1 : 0) +
                           (GetPartHealth(ERelBodyPart::RightLeg) < CriticalThreshold ? 1 : 0);
    return HurtLegs == 2 ? 0.3f : HurtLegs == 1 ? 0.6f : 1.f;
}

float URelBodyComponent::GetAimPenalty() const
{
    return (GetPartHealth(ERelBodyPart::LeftArm) < CriticalThreshold ||
            GetPartHealth(ERelBodyPart::RightArm) < CriticalThreshold) ? 1.6f : 1.f;
}

void URelBodyComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{
    Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
    if (bDead || DeltaTime <= 0.f) return;
    if (bPoisoned) DamagePart(PoisonedPart, 0.6f * DeltaTime);
}