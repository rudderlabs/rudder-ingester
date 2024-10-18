package main

import (
	"regexp"
	"strconv"
	"strings"
	"text/template"
)

type eventGenerator func(t *template.Template, userID, loadRunID string, n []int) []byte

var eventGenerators = map[string]eventGenerator{
	"page":  pageFunc,
	"batch": batchFunc,
}

var (
	pageFunc eventGenerator = func(t *template.Template, userID, loadRunID string, n []int) []byte {
		return nil
	}
	batchFunc eventGenerator = func(t *template.Template, userID, loadRunID string, n []int) []byte {
		return nil
	}

	eventTypesRegexp = regexp.MustCompile(`(\w+)(\(([\d,]+)\))?`)
)

type eventType struct {
	Type   string
	Values []int
}

func parseEventTypes(input string) ([]eventType, error) {
	matches := eventTypesRegexp.FindAllStringSubmatch(input, -1)
	events := make([]eventType, 0, len(matches))
	for _, match := range matches {
		et := match[1] // First group: the type (e.g., 'page', 'batch')
		var values []int
		if match[3] != "" { // Third group: the comma-separated numbers inside parentheses
			valuesSplit := strings.Split(match[3], ",")
			values = make([]int, 0, len(valuesSplit))
			for _, v := range valuesSplit {
				val, err := strconv.Atoi(v)
				if err != nil {
					return nil, err
				}
				values = append(values, val)
			}
		}
		events = append(events, eventType{Type: et, Values: values})
	}
	return events, nil
}

func getEventTypesConcentration(
	loadRunID string,
	eventTypes []eventType,
	hotEventTypes []int,
	eventGenerators map[string]eventGenerator,
	templates map[string]*template.Template,
) []func(userID string) []byte {
	totalPercentage := 0
	for _, percentage := range hotEventTypes {
		totalPercentage += percentage
	}
	if totalPercentage != 100 {
		panic("hot event types percentages do not sum up to 100")
	}
	if len(eventTypes) != len(hotEventTypes) {
		panic("event types and hot event types must have the same length")
	}

	var (
		startID             = 0
		eventsConcentration = make([]func(string) []byte, 100)
	)
	for i, hotEventPercentage := range hotEventTypes {
		et := eventTypes[i]
		f := func(userID string) []byte {
			return eventGenerators[et.Type](templates[et.Type], userID, loadRunID, et.Values)
		}
		for i := startID; i < hotEventPercentage+startID; i++ {
			eventsConcentration[i] = f
		}
		startID += hotEventPercentage
	}

	return eventsConcentration
}
