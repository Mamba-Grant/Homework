year = int(input("Enter a year: "))

is_leap_year = (year % 4 == 0 and year % 100 != 0) or year % 400 == 0

print(f"{year} IS {'a' if is_leap_year else 'NOT a'} leap year.")
