def add(num1, num2):
    result = num1 + num2
    return result


def sub(num1, num2):
    result = num1 - num2
    return result


def mul(num1, num2):
    result = num1 * num2
    return result


def div(num1, num2):
    try:
        result = num1 / num2
        return result
    except ZeroDivisionError:
        return "Division by Zero!"


print("Select operation: \n 1. Add \n 2. Subtract \n 3. Multiply. \n 4. Divide \n ")

while True:
    operation = input("Enter choice(1/2/3/4): ")

    if operation in ('1', '2', '3', '4'):
        try:
            firstNumber = float(input("Enter first number: "))
            secondNumber = float(input("Enter second number: "))
        except ValueError:
            print("Not a number! Please enter a number.")
            continue

        match operation:
            case "1":
                addition = add(firstNumber, secondNumber)
                print("The result of the addition is: ", addition)

            case "2":
                subtraction = sub(firstNumber, secondNumber)
                print("The result of the subtraction is: ", subtraction)

            case "3":
                multiplication = mul(firstNumber, secondNumber)
                print("The result of the multiplication is: ", multiplication)

            case "4":
                division = div(firstNumber, secondNumber)
                print("The result of the division is: ", division)

        cont = input("Would you like to do a new calculation? (yes/no):")
        if cont == "no":
            break
    else:
        print("Wrong operation ! Please choose the right operation.")
