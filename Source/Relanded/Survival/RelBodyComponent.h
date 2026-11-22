#pragma once
#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "RelBodyComponent.generated.h"

UENUM(BlueprintType)
enum class ERelBodyPart : uint8 { Head, Torso, LeftArm, RightArm, LeftLeg, RightLeg };

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FRelPartChanged, ERelBodyPart, Part, float, NewHealth);
DECLARE_DYNAMIC_MULTICAST_DELEGATE(FRelFatalInjury);

// Estado das seis partes do corpo. Pode ser ligado à HUD e ao inventário via Blueprint.
UCLASS(ClassGroup=(Survival), meta=(BlueprintSpawnableComponent))
class RELANDED_API URelBodyComponent : public UActorComponent
{
    GENERATED_BODY()
public:
    URelBodyComponent();

    UFUNCTION(BlueprintCallable, Category="Body") void DamagePart(ERelBodyPart Part, float Amount);
    UFUNCTION(BlueprintCallable, Category="Body") void DamageRandomPart(float Amount);
    UFUNCTION(BlueprintCallable, Category="Body") void Poison(ERelBodyPart Part);
    UFUNCTION(BlueprintCallable, Category="Body") void ApplyMedicine(ERelBodyPart Part, float HealAmount = 40.f);
    UFUNCTION(BlueprintCallable, Category="Body") bool ApplySplint(ERelBodyPart Part);

    UFUNCTION(BlueprintPure, Category="Body") float GetPartHealth(ERelBodyPart Part) const;
    UFUNCTION(BlueprintPure, Category="Body") bool IsPoisoned() const { return bPoisoned; }
    UFUNCTION(BlueprintPure, Category="Body") ERelBodyPart GetPoisonedPart() const { return PoisonedPart; }
    UFUNCTION(BlueprintPure, Category="Body") bool IsDead() const { return bDead; }
    UFUNCTION(BlueprintPure, Category="Body") float GetMoveSpeedMultiplier() const;
    UFUNCTION(BlueprintPure, Category="Body") float GetAimPenalty() const;

    UPROPERTY(BlueprintAssignable, Category="Body") FRelPartChanged OnPartChanged;
    UPROPERTY(BlueprintAssignable, Category="Body") FRelFatalInjury OnFatalInjury;
    virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

private:
    UPROPERTY() TArray<float> PartHealth;
    bool bPoisoned = false;
    bool bDead = false;
    ERelBodyPart PoisonedPart = ERelBodyPart::LeftLeg;
    static constexpr float CriticalThreshold = 35.f;
    bool IsValidPart(ERelBodyPart Part) const;
    void SetPart(ERelBodyPart Part, float NewValue);
};