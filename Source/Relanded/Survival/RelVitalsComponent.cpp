#include "Survival/RelVitalsComponent.h"

URelVitalsComponent::URelVitalsComponent()
{
    PrimaryComponentTick.bCanEverTick = true;
}

void URelVitalsComponent::SetSprinting(bool bNewSprinting)
{
    bSprinting = bNewSprinting;
}

void URelVitalsComponent::Eat(float Amount)
{
    if (Amount > 0.f && !bDead) Hunger = FMath::Clamp(Hunger + Amount, 0.f, 100.f);
}

bool URelVitalsComponent::Drink(float Amount, bool bClean)
{
    if (Amount <= 0.f || bDead) return false;
    Thirst = FMath::Clamp(Thirst + Amount, 0.f, 100.f);
    return !bClean && FMath::FRand() < 0.6f;
}

void URelVitalsComponent::SleepFully()
{
    if (bDead) return;
    Sleep = 100.f;
    Hunger = FMath::Max(0.f, Hunger - 20.f);
    Thirst = FMath::Max(0.f, Thirst - 20.f);
    Health = FMath::Min(100.f, Health + 25.f);
}

void URelVitalsComponent::ApplyDamage(float Amount)
{
    if (Amount <= 0.f || bDead) return;
    Health = FMath::Max(0.f, Health - Amount);
    CheckDeath();
}

void URelVitalsComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{
    Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
    if (bDead || DeltaTime <= 0.f) return;

    Hunger = FMath::Max(0.f, Hunger - HungerPerSecond * DeltaTime);
    Thirst = FMath::Max(0.f, Thirst - ThirstPerSecond * DeltaTime);
    Sleep = FMath::Max(0.f, Sleep - SleepPerSecond * DeltaTime);

    if (bSprinting && CanSprint())
    {
        Stamina = FMath::Max(0.f, Stamina - SprintDrainPerSecond * DeltaTime);
        if (Stamina <= 0.f) bExhausted = true;
    }
    else
    {
        Stamina = FMath::Min(100.f, Stamina + StaminaRegenPerSecond * DeltaTime);
        if (bExhausted && Stamina > 25.f) bExhausted = false;
    }

    if (Hunger <= 0.f || Thirst <= 0.f || Sleep <= 0.f)
        Health = FMath::Max(0.f, Health - 2.f * DeltaTime);

    CheckDeath();
}

void URelVitalsComponent::CheckDeath()
{
    if (!bDead && Health <= 0.f)
    {
        bDead = true;
        bSprinting = false;
        OnDied.Broadcast();
    }
}