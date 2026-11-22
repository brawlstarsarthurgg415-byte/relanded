#pragma once
#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "RelVitalsComponent.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE(FRelDied);

// Necessidades do jogador: valores entre 0 e 100.
UCLASS(ClassGroup=(Survival), meta=(BlueprintSpawnableComponent))
class RELANDED_API URelVitalsComponent : public UActorComponent
{
    GENERATED_BODY()
public:
    URelVitalsComponent();

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Vitals", meta=(ClampMin="0", ClampMax="100")) float Health = 100.f;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Vitals", meta=(ClampMin="0", ClampMax="100")) float Stamina = 100.f;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Vitals", meta=(ClampMin="0", ClampMax="100")) float Hunger = 90.f;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Vitals", meta=(ClampMin="0", ClampMax="100")) float Thirst = 90.f;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Vitals", meta=(ClampMin="0", ClampMax="100")) float Sleep = 100.f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Rates", meta=(ClampMin="0")) float HungerPerSecond = 0.22f;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Rates", meta=(ClampMin="0")) float ThirstPerSecond = 0.32f;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Rates", meta=(ClampMin="0")) float SleepPerSecond = 0.10f;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Rates", meta=(ClampMin="0")) float SprintDrainPerSecond = 24.f;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Rates", meta=(ClampMin="0")) float StaminaRegenPerSecond = 16.f;

    UFUNCTION(BlueprintCallable, Category="Survival") void SetSprinting(bool bNewSprinting);
    UFUNCTION(BlueprintPure, Category="Survival") bool CanSprint() const { return !bExhausted && Stamina > 0.f && !bDead; }
    UFUNCTION(BlueprintCallable, Category="Survival") void Eat(float Amount);
    // Retorna true quando a água não tratada provoca uma chance de doença.
    UFUNCTION(BlueprintCallable, Category="Survival") bool Drink(float Amount, bool bClean);
    UFUNCTION(BlueprintCallable, Category="Survival") void SleepFully();
    UFUNCTION(BlueprintCallable, Category="Survival") void ApplyDamage(float Amount);
    UFUNCTION(BlueprintPure, Category="Survival") bool IsDead() const { return bDead; }

    UPROPERTY(BlueprintAssignable, Category="Survival") FRelDied OnDied;
    virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

private:
    bool bSprinting = false;
    bool bExhausted = false;
    bool bDead = false;
    void CheckDeath();
};